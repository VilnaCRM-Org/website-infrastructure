"""Exercise the real shell loader with synthetic secrets and a stubbed AWS CLI."""

import json
import os
from pathlib import Path
import subprocess
import sys
import unittest

LOADER = Path(__file__).resolve().parents[1] / "sh" / "retrieve_token.sh"
HARNESS = r"""
set -euo pipefail
aws() {
  case "$1 $2" in
    'secretsmanager list-secrets') printf '%s\n' 'github-token-synthetic' ;;
    'secretsmanager get-secret-value') printf '%s\n' "$SYNTHETIC_SECRET" ;;
    *) echo 'Unexpected AWS operation' >&2; return 99 ;;
  esac
}
source "$1"
"$2" -c 'import json, os; assert os.environ["GITHUB_TOKEN"] == json.loads(os.environ["SYNTHETIC_SECRET"])["token"]'
echo 'Child received exact token'
"""


class TokenLoaderTests(unittest.TestCase):
    def run_loader(self, secret):
        # Do not inherit credentials or a pre-exported GITHUB_TOKEN from the host.
        return subprocess.run(
            [
                "bash",
                "--noprofile",
                "--norc",
                "-c",
                HARNESS,
                "token-test",
                str(LOADER),
                sys.executable,
            ],
            env={
                "PATH": os.environ.get("PATH", os.defpath),
                "AWS_DEFAULT_REGION": "eu-central-1",
                "SYNTHETIC_SECRET": json.dumps(secret),
            },
            capture_output=True,
            text=True,
            timeout=10,
        )

    def test_long_installation_token_is_exported_unchanged(self):
        token = "ghs_" + "x" * 373
        result = self.run_loader({"token": token, "expires_at": "2099-01-01T00:00:00Z"})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Child received exact token", result.stdout)
        self.assertNotIn(token, result.stdout + result.stderr)

    def test_opaque_tokens_have_no_prefix_or_length_requirement(self):
        for token in ["x", "synthetic.v2_token-+/=", "null"]:
            with self.subTest(token=token):
                result = self.run_loader({"token": token})
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("Child received exact token", result.stdout)

    def test_missing_null_nonstring_and_empty_tokens_are_rejected(self):
        secrets = [{}, *({"token": value} for value in [None, 123, True, [], {}, ""])]
        for secret in secrets:
            with self.subTest(secret=secret):
                result = self.run_loader(secret)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("nonempty string", result.stdout)
                self.assertNotIn("Child received exact token", result.stdout)

    def test_whitespace_and_control_characters_are_rejected_before_extraction(self):
        for token in [
            " ",
            "\t\n",
            " synthetic",
            "synthetic ",
            "syn thetic",
            "synthetic\n",
            "syn\tthetic",
            "syn\x00thetic",
        ]:
            with self.subTest(token=repr(token)):
                result = self.run_loader({"token": token})
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("nonempty string", result.stdout)
                self.assertNotIn("Child received exact token", result.stdout)

    def test_expired_token_is_rejected(self):
        result = self.run_loader(
            {"token": "synthetic-token", "expires_at": "2000-01-01T00:00:00Z"}
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GitHub token has expired", result.stdout)
        self.assertNotIn("Child received exact token", result.stdout)


if __name__ == "__main__":
    unittest.main()
