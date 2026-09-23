"""Run the infrastructure handoff with local stubs; never call AWS or apply IaC."""

import os
from pathlib import Path
import subprocess
import unittest

import yaml


ROOT = Path(__file__).resolve().parents[3]
BUILDSPEC = ROOT / "aws/buildspecs/ci-cd-infrastructure/up.yml"
REVISION = "ee5a6898e6d96d684575743bba4ec290a89c12ae"
STACKS = ["ci-cd-infrastructure", "ci-cd-iam", "website-iam", "iam-groups"]
STUBS = r"""
set -euo pipefail
make() {
  printf 'MAKE %s\n' "$*"
  if [[ "$1" == 'terraspace-up-plan' && "$2" == "stack=${FAIL_STACK}" ]]; then
    return 23
  fi
  if [[ "$1" == 'terraspace-output-file' && "$FAIL_OUTPUT" == 'true' ]]; then
    return 24
  fi
}
sed() {
  [[ "$3" == "${CODEBUILD_SRC_DIR}/terraform/.ci-cd-infrastructure.env" ]] || return 25
  printf '%s\n' "$PIPELINE_OUTPUT" | /usr/bin/sed "$1" "$2"
}
aws() {
  printf 'AWS %s\n' "$*"
}
"""


class PipelineOrchestrationTests(unittest.TestCase):
    def run_handoff(self, **overrides):
        commands = yaml.safe_load(BUILDSPEC.read_text())["phases"]["build"]["commands"]
        # Exercise the actual saved-plan apply commands and final handoff block,
        # in their original order. Installation and credential loading are excluded.
        handoff = "\n".join(
            command for command in commands
            if "make terraspace-up-plan" in command
            or "make terraspace-output-file" in command
        )
        env = {
            "PATH": os.defpath,
            "CODEBUILD_SRC_DIR": str(ROOT),
            "CODEBUILD_RESOLVED_SOURCE_VERSION": REVISION,
            "PIPELINE_OUTPUT": 'website_infra_pipeline_name = "website-infra-test-pipeline"',
            "FAIL_STACK": "",
            "FAIL_OUTPUT": "false",
        }
        env.update(overrides)
        return subprocess.run(
            ["bash", "--noprofile", "--norc"],
            input=STUBS + handoff,
            env=env,
            capture_output=True,
            text=True,
            timeout=10,
        )

    def test_starts_once_after_all_applies_with_the_exact_revision(self):
        result = self.run_handoff()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [
            *(f"MAKE terraspace-up-plan stack={stack} plan={stack}.plan" for stack in STACKS),
            "MAKE terraspace-output-file stack=ci-cd-infrastructure out=.ci-cd-infrastructure.env",
            "AWS codepipeline start-pipeline-execution --name website-infra-test-pipeline "
            f"--source-revisions actionName=Download-Source,revisionType=COMMIT_ID,revisionValue={REVISION}",
        ])

    def test_each_failed_apply_prevents_the_handoff(self):
        for stack in STACKS:
            with self.subTest(stack=stack):
                result = self.run_handoff(FAIL_STACK=stack)
                self.assertEqual(result.returncode, 23, result.stderr)
                self.assertNotIn("AWS ", result.stdout)

    def test_failed_output_read_prevents_the_handoff(self):
        result = self.run_handoff(FAIL_OUTPUT="true")
        self.assertEqual(result.returncode, 24, result.stderr)
        self.assertNotIn("AWS ", result.stdout)

    def test_missing_pipeline_prevents_the_handoff(self):
        result = self.run_handoff(PIPELINE_OUTPUT="")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing website pipeline output", result.stderr)
        self.assertNotIn("AWS ", result.stdout)

    def test_missing_revision_prevents_the_handoff(self):
        result = self.run_handoff(CODEBUILD_RESOLVED_SOURCE_VERSION="")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing source revision", result.stderr)
        self.assertNotIn("AWS ", result.stdout)


if __name__ == "__main__":
    unittest.main()
