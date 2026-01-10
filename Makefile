# Executables: local only
DOCKER_COMPOSE = docker compose -f docker/docker-compose.yml run --rm
DOCKER         = docker
MAKE           = make
BUNDLE         = bundle
CD             = cd
# Terraform and related tools
TERRAFORM      = terraform
TERRASPACE     = terraspace
TFENV          = tfenv
# Common system commands
GIT            = git
ECHO           = echo
CURL           = curl
CHMOD          = chmod
EXPORT         = export
RM             = rm

# Misc
.DEFAULT_GOAL = help
.RECIPEPREFIX +=
.PHONY: $(filter-out vendor node_modules,$(MAKECMDGOALS))
.TERRAFORM_DIR = ./terraform

# Executables
GO_TO_TERRAFORM_DIR = $(CD) $(.TERRAFORM_DIR)

TERRASPACE_ENVIRONMENT = TS_ENV=$(if $(env),$(env),$(TS_ENV))

EXEC_TS = $(GO_TO_TERRAFORM_DIR) && $(TERRASPACE_ENVIRONMENT) $(TERRASPACE) 

help:
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

terraform: ## Terraform enables you to safely and predictably create, change, and improve infrastructure.
	${DOCKER_COMPOSE} terraform "$1"

tf-fmt: ## Format terraform code recursively.
	$(TERRAFORM) fmt --recursive

terraform-compliance: ## Terraform compliance is a security and compliance focused test framework.
	${DOCKER_COMPOSE} terraform-compliance

terraspace: ## Terraspace is a terraform framework.
	${DOCKER_COMPOSE} --build terraspace

codebuild-local-set-up: ## Setting up CodeBuild Agent for testing buildspecs locally
	$(DOCKER) pull public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:5.0
	$(DOCKER) pull public.ecr.aws/codebuild/local-builds:latest
	@$(CURL) -f -O https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh || \
		{ echo "Failed to download codebuild_build.sh" >&2; exit 1; }
	@$(CHMOD) +x codebuild_build.sh || \
		{ echo "Failed to set executable permissions" >&2; $(RM) -f codebuild_build.sh; exit 1; }

codebuild-run: ## Running CodeBuild for specific buildspec. Example: make codebuild-run buildspec='aws/buildspecs/website/buildspec_deploy.yml'
	./codebuild_build.sh -i $(image) -d -a codebuild_artifacts -b $(buildspec) -e .env -m

TERRAFORM_VERSION ?= 1.10.5

install-terraspace: ## Install terraspace locally.
	@$(ECHO) "## Install OpenTofu"
	$(CURL) --proto "=https" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
	$(CHMOD) +x install-opentofu.sh
	./install-opentofu.sh --install-method rpm || { $(ECHO) "Failed to install OpenTofu" && exit 1; }
	$(RM) install-opentofu.sh
	@$(ECHO) "## Install Terraform"
	$(GIT) clone https://github.com/tfutils/tfenv.git ~/.tfenv
	$(ECHO) 'export PATH="$$HOME/.tfenv/bin:$$PATH"' >>~/.bash_profile
	$(EXPORT) PATH="$HOME/.tfenv/bin:$PATH"
	$(TFENV) install $(TERRAFORM_VERSION) || { $(ECHO) "Failed to install Terraform" && exit 1; }
	$(TFENV) use $(TERRAFORM_VERSION)

# Terraspace All

terraspace-all-init: ## Init all the stacks. 
	$(EXEC_TS) all init

terraspace-all-validate: ## Validate all the stacks. 
	$(EXEC_TS) all validate

terraspace-all-plan: ## Plan all the stacks. Variables: env.
	$(EXEC_TS) all plan -y 

terraspace-all-plan-file: ## Plan all the stacks into file. Variables: env, out.
	$(EXEC_TS) all plan --out $(out) -y 

terraspace-all-up: ## Up all the stacks. Variables: env.
	$(EXEC_TS) all up -y

terraspace-all-up-plan: ## Up all the stacks from the plan. Variables: env, plan.
	$(EXEC_TS) all up --plan $(plan) -y

terraspace-all-output: ## Output all the stacks variables. Variables: env.
	$(EXEC_TS) all output -y

terraspace-all-output-file: ## Output all the stacks variables into file. Variables: env, out.
	$(EXEC_TS) all output > $(out) -y

terraspace-all-down: ## Down all the stacks.
	$(EXEC_TS) all down -y

# Terraspace Init

terraspace-init: ## Init the stack. Variables: env, stack.
	$(EXEC_TS) init $(stack) 

# Terraspace Validate

terraspace-validate: ## Validate the stack. Variables: env, stack.
	$(EXEC_TS) validate $(stack) 

# Terraspace Plan

terraspace-plan: ## Plan the stack. Variables: env, stack.
	$(EXEC_TS) plan $(stack) 

terraspace-plan-file: ## Plan the stack into file. Variables: env, stack, out.
	$(EXEC_TS) plan $(stack) --out $(out)

# Terraspace Up

terraspace-up: ## Up the stack. Variables: env, stack.
	$(EXEC_TS) up $(stack) -y

terraspace-up-plan: ## Up the stack from plan. Variables: env, stack, plan.
	$(EXEC_TS) up $(stack) --plan $(plan) -y 

terraspace-docker-plan: ## Plan the stack via docker compose (uses host env vars from shell, incl. ~/.bashrc). Variables: env, stack.
	bash -lc "source ~/.bashrc >/dev/null 2>&1; TS_ENV=$(if $(env),$(env),$(TS_ENV)) docker compose -f docker/docker-compose.yml run --rm --entrypoint /bin/bash terraspace -lc 'terraspace plan $(stack)'"

terraspace-docker-up: ## Up the stack via docker compose (uses host env vars from shell, incl. ~/.bashrc). Variables: env, stack.
	bash -lc "source ~/.bashrc >/dev/null 2>&1; TS_ENV=$(if $(env),$(env),$(TS_ENV)) docker compose -f docker/docker-compose.yml run --rm --entrypoint /bin/bash terraspace -lc 'terraspace up $(stack) -y'"

# Terraspace Output

terraspace-output: ## Output the stack variables. Variables: env, stack.
	$(EXEC_TS) output $(stack)

terraspace-output-file: ## Output the stack variables into file. Variables: env, stack, out.
	$(EXEC_TS) output $(stack) > $(out) -y

# Terraspace Down

terraspace-down: ## Down the stack. Variables: env, stack.
	$(EXEC_TS) down $(stack) -y

pr-comments: ## Retrieve unresolved PR review comments (auto-detects current PR). Variables: PR, FORMAT.
ifdef PR
	@GITHUB_HOST="$(GITHUB_HOST)" INCLUDE_OUTDATED="true" \
		./scripts/get-pr-comments.sh "$(PR)" "$${FORMAT:-text}"
else
	@GITHUB_HOST="$(GITHUB_HOST)" INCLUDE_OUTDATED="true" \
		./scripts/get-pr-comments.sh "$${FORMAT:-text}"
endif
