# AGENTS.md

## Project overview
- AWS infrastructure for VilnaCRM, managed with Terraform + Terraspace.
- CI/CD uses CodePipeline/CodeBuild with buildspecs in `aws/buildspecs`.
- Common automation scripts live in `aws/scripts` (shell + Python).

## Key paths
- `terraform/`: Terraspace stacks, modules, and variables.
- `aws/buildspecs/`: CodeBuild buildspecs for website, sandbox, and CI/CD infra.
- `aws/scripts/sh/`: Shell helpers used by buildspecs (Docker setup, install, etc.).
- `aws/scripts/py/`: Python helpers for deploy, cache invalidation, reports.
- `docker/`: Local Docker Compose tooling.
- `task/`, `hurl/`: Task runner and healthcheck assets.
- `.github/workflows/`: GitHub Actions.

## Common commands
- `make help`: list available targets.
- `make tf-fmt`: format Terraform files.
- `make terraspace-validate stack=<stack> env=<env>`: validate a stack.
- `make terraspace-plan stack=<stack> env=<env>`: plan a stack.
- `make terraspace-all-validate env=<env>`: validate all stacks.
- `make codebuild-local-set-up`: download CodeBuild local tools.
- `make codebuild-run buildspec=<path> image=<image>`: run a buildspec locally.

## Environment and config
- Terraspace uses `TS_ENV` or `env=<env>` in make targets.
- Terraform variables are typically provided via tfvars and `TF_VAR_*`.
- Local CodeBuild runs expect `.env` for environment variables.

## Safety and expectations
- Avoid running `terraspace up/down` or any apply-style commands unless explicitly requested.
- Do not modify AWS resources directly from this repo without confirmation.
- Keep changes scoped; prefer editing buildspecs/scripts over generated artifacts.

## PR/issue hygiene
- Reference issues in PR descriptions when relevant.
- Keep commits focused and small.
