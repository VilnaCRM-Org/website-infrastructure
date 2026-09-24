"""Offline contracts for PR trust lanes. Run with unittest; requires PyYAML."""

import itertools
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import yaml

ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS = {
    "super-linter.yml": ("lint", "lint"),
    "infracost.yml": ("infracost", "run infracost"),
    "tf_docs.yml": ("terraform-docs", "terraform-docs"),
}
LANES = ("internal", "fork", "dependabot")
BOT = "dependabot[bot]"


def load_workflow(name):
    with (ROOT / ".github" / "workflows" / name).open() as source:
        return yaml.safe_load(source)


def selected(condition, context):
    """Evaluate only the equality/boolean expressions used for lane routing."""
    expression = condition.strip()
    for key, value in sorted(context.items(), key=lambda item: -len(item[0])):
        expression = expression.replace(key, repr(value))
    expression = expression.replace("&&", " and ").replace("||", " or ")
    expression = " ".join(expression.split())
    return eval(expression, {"__builtins__": {}}, {})


def isolated_env(extra=None):
    """Keep offline Git fixtures independent of the invoking repository."""
    env = {
        key: value for key, value in os.environ.items() if not key.startswith("GIT_")
    }
    env.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
    env.update(extra or {})
    return env


def run_script(script, env, cwd=None):
    return subprocess.run(
        ["bash", "-e", "-c", script],
        env=isolated_env(env),
        cwd=cwd,
        capture_output=True,
        text=True,
        check=False,
    )


class WorkflowContracts(unittest.TestCase):
    def test_read_only_boundaries(self):
        for filename, (gate_id, check_name) in WORKFLOWS.items():
            with self.subTest(workflow=filename):
                workflow = load_workflow(filename)
                # PyYAML's YAML 1.1 loader reads the "on" key as True.
                self.assertEqual(
                    workflow[True], {"pull_request": {"branches": ["main"]}}
                )
                self.assertEqual(workflow["permissions"], {"contents": "read"})
                jobs = workflow["jobs"]
                gate = jobs[gate_id]
                self.assertEqual(gate.get("name", gate_id), check_name)
                self.assertEqual(gate["if"], "${{ always() }}")
                self.assertEqual(set(gate["needs"]), set(LANES))
                self.assertEqual(gate["permissions"], {"contents": "read"})
                self.assertNotIn("uses", str(gate))
                for lane in ("fork", "dependabot"):
                    job = jobs[lane]
                    self.assertEqual(job["permissions"], {"contents": "read"})
                    serialized = json.dumps(job)
                    for forbidden in (
                        "secrets.",
                        "github.token",
                        "GITHUB_TOKEN",
                        "github-app-token",
                        "git-auto-commit",
                        "continue-on-error",
                        "id-token",
                    ):
                        self.assertNotIn(forbidden, serialized)
                    checkouts = [
                        step
                        for step in job["steps"]
                        if step.get("uses", "").startswith("actions/checkout@")
                    ]
                    self.assertEqual(len(checkouts), 1)
                    self.assertIs(checkouts[0]["with"]["persist-credentials"], False)

    def test_lane_routing_and_terminal_results(self):
        for filename, (gate_id, _) in WORKFLOWS.items():
            jobs = load_workflow(filename)["jobs"]
            script = jobs[gate_id]["steps"][0]["run"]
            for fork, author_bot, actor_bot, rerun_bot in itertools.product(
                (False, True), repeat=4
            ):
                head = "person/repo" if fork else "org/repo"
                author = BOT if author_bot else "human"
                actor = BOT if actor_bot else "human"
                rerun = BOT if rerun_bot else "human"
                bot = author_bot or actor_bot or rerun_bot
                expected = "fork" if fork else "dependabot" if bot else "internal"
                context = {
                    "github.event.pull_request.head.repo.full_name": head,
                    "github.event.pull_request.base.repo.full_name": "org/repo",
                    "github.event.pull_request.user.login": author,
                    "github.actor": actor,
                    "github.triggering_actor": rerun,
                }
                routed = [lane for lane in LANES if selected(jobs[lane]["if"], context)]
                self.assertEqual(routed, [expected])
                env = {
                    "HEAD_REPO": head,
                    "BASE_REPO": "org/repo",
                    "AUTHOR": author,
                    "ACTOR": actor,
                    "TRIGGERING_ACTOR": rerun,
                }
                for result in ("success", "failure", "cancelled", "skipped"):
                    needs = {
                        lane: {"result": result if lane == expected else "skipped"}
                        for lane in LANES
                    }
                    outcome = run_script(script, {**env, "RESULTS": json.dumps(needs)})
                    with self.subTest(
                        workflow=filename, context=context, result=result
                    ):
                        self.assertEqual(
                            outcome.returncode == 0,
                            result == "success",
                            outcome.stderr,
                        )
                needs = {lane: {"result": "success"} for lane in LANES}
                self.assertNotEqual(
                    run_script(
                        script, {**env, "RESULTS": json.dumps(needs)}
                    ).returncode,
                    0,
                )
                self.assertNotEqual(
                    run_script(
                        script,
                        {**env, "HEAD_REPO": "", "RESULTS": json.dumps(needs)},
                    ).returncode,
                    0,
                )

    def test_linter_and_docs_are_checks_only(self):
        lint = load_workflow("super-linter.yml")["jobs"]
        docs = load_workflow("tf_docs.yml")["jobs"]
        for lane in ("fork", "dependabot"):
            env = lint[lane]["steps"][1]["env"]
            self.assertIs(env["MULTI_STATUS"], False)
            self.assertIs(env["VALIDATE_ALL_CODEBASE"], True)
            fixes = [value for key, value in env.items() if key.startswith("FIX_")]
            self.assertTrue(fixes)
            self.assertTrue(all(value is False for value in fixes))
            self.assertEqual(docs[lane]["steps"][1]["with"]["git-push"], "false")
            self.assertEqual(docs[lane]["steps"][1]["with"]["fail-on-diff"], "true")
            self.assertEqual(docs[lane]["steps"][2]["run"], "git diff --exit-code HEAD")
        self.assertEqual(docs["internal"]["steps"][1]["with"]["git-push"], "true")
        self.assertIn("secrets.VILNACRM_APP_PRIVATE_KEY", str(lint["internal"]))
        self.assertIn(
            "secrets.INFRACOST_API_KEY",
            str(load_workflow("infracost.yml")["jobs"]["internal"]),
        )


class GitDiffContracts(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.repo = Path(self.temporary.name)
        self.git("init", "-q")
        self.git("config", "user.name", "Offline test")
        self.git("config", "user.email", "offline@example.invalid")
        self.git("config", "commit.gpgsign", "false")
        self.write("README.md", "Documentation\n")
        self.write("terraform/main.tf", "# infrastructure\n")
        self.base = self.commit()
        jobs = load_workflow("infracost.yml")["jobs"]
        fork = jobs["fork"]["steps"]
        dependabot = jobs["dependabot"]["steps"]
        self.assertEqual(fork, dependabot)
        self.assertEqual(fork[0]["with"]["fetch-depth"], 0)
        self.script = fork[1]["run"]

    def git(self, *args):
        return subprocess.check_output(
            ["git", *args],
            cwd=self.repo,
            env=isolated_env(),
            stderr=subprocess.PIPE,
            text=True,
        ).strip()

    def write(self, path, content):
        target = self.repo / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)

    def commit(self):
        self.git("add", "--all")
        self.git("commit", "-qm", "Offline fixture")
        return self.git("rev-parse", "HEAD")

    def check(self, head, success, base=None):
        result = run_script(
            self.script,
            {"BASE_SHA": base or self.base, "HEAD_SHA": head},
            cwd=self.repo,
        )
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def test_allowed_changes_and_empty_diff(self):
        self.check(self.base, True)
        self.write(".github/workflows/infracost.yml", "workflow fixture\n")
        self.write("tests/test_fork_pr_ci_safety.py", "# test fixture\n")
        self.write("README.md", "Updated documentation\n")
        self.check(self.commit(), True)

    def test_git_subprocesses_ignore_inherited_repository_state(self):
        poison = {
            "GIT_DIR": str(self.repo / "not-this-repository.git"),
            "GIT_INDEX_FILE": str(self.repo / "not-this-index"),
            "GIT_CONFIG_GLOBAL": str(self.repo / "not-this-config"),
        }
        with patch.dict(os.environ, poison):
            self.assertEqual(Path(self.git("rev-parse", "--show-toplevel")), self.repo)
            result = run_script(
                'test "$EXPLICIT_VALUE" = present && git rev-parse --show-toplevel',
                {"EXPLICIT_VALUE": "present"},
                cwd=self.repo,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(Path(result.stdout.strip()), self.repo)
            self.assertEqual(isolated_env()["GIT_CONFIG_GLOBAL"], os.devnull)

    def test_docs_detect_staged_and_unstaged_changes(self):
        jobs = load_workflow("tf_docs.yml")["jobs"]
        for lane in ("fork", "dependabot"):
            script = jobs[lane]["steps"][2]["run"]
            self.assertEqual(run_script(script, {}, self.repo).returncode, 0)
            self.write("README.md", "Generated documentation\n")
            self.assertNotEqual(run_script(script, {}, self.repo).returncode, 0)
            # terraform-docs stages generated files even with git-push=false.
            self.git("add", "README.md")
            self.assertNotEqual(run_script(script, {}, self.repo).returncode, 0)
            self.write("README.md", "Documentation\n")
            self.git("add", "README.md")

    def test_all_unknown_and_iac_inputs_fail(self):
        for path in (
            "terraform/main.tf",
            "terraform/.terraform.lock.hcl",
            "terraform/plan.json",
            "terraform/config/app.rb",
            "terraform/Terrafile",
            "Gemfile.lock",
            ".github/workflows/ci-cd-infra.yml",
            "aws/buildspecs/ci-cd-infrastructure/plan.yml",
            "new.tfvars.json",
            "terraform/README.md",
            "space and\nnewline.tf",
        ):
            with self.subTest(path=path):
                self.write(path, "changed input\n")
                self.check(self.commit(), False)
                # Each next candidate has no other changes relative to its base.
                self.base = self.git("rev-parse", "HEAD")

    def test_deleted_iac_input_fails(self):
        (self.repo / "terraform/main.tf").unlink()
        self.check(self.commit(), False)

    def test_rename_iac_to_allowed_path_fails(self):
        self.git("mv", "terraform/main.tf", "CHANGELOG.md")
        result = self.check(self.commit(), False)
        self.assertIn("terraform/main.tf", result.stdout)

    def test_rename_allowed_path_to_iac_fails(self):
        self.git("mv", "README.md", "terraform/README.md")
        self.check(self.commit(), False)

    def test_complete_history_over_300_files(self):
        for index in range(305):
            self.write(f"README-{index}.md", "fixture\n")
        self.write("terraform/last.tf", "# change\n")
        result = self.check(self.commit(), False)
        self.assertIn("terraform/last.tf", result.stdout)
        self.assertEqual(result.stdout.count("Requires trusted cost estimation:"), 306)

    def test_base_advance_does_not_hide_pr_changes(self):
        self.git("checkout", "-qb", "pr")
        self.write("terraform/main.tf", "# PR change\n")
        head = self.commit()
        self.git("checkout", "-q", self.base)
        self.write("terraform/main.tf", "# PR change\n")
        self.write("README.md", "Base advanced independently\n")
        advanced_base = self.commit()
        self.assertNotEqual(head, advanced_base)
        self.check(head, False, base=advanced_base)

    def test_missing_invalid_and_unrelated_history_fails(self):
        self.check("0" * 40, False)
        self.check("--help", False)
        self.check("", False)
        self.git("checkout", "--orphan", "unrelated")
        self.write("README.md", "Unrelated history\n")
        self.check(self.commit(), False)


if __name__ == "__main__":
    unittest.main()
