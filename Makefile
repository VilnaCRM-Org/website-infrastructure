# Executables: local only
DOCKER_COMPOSE = docker compose -f docker/docker-compose.yml run --rm
DOCKER         = docker
MAKE 		   = make
BUNDLE		   = bundle
CD 	           = cd
TERRAFORM 	   = terraform
TERRASPACE	   = terraspace
TFENV		   = tfenv
GIT 		   = git
ECHO 		   = echo
CURL		   = curl
CHMOD		   = chmod
EXPORT 		   = export
RM 		   = rm

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

tf-fmt: # Format terraform code recursively.
	$(TERRAFORM) fmt --recursive

terraform-compliance: ## Terraform compliance is a security and compliance focused test framework.
	${DOCKER_COMPOSE} terraform-compliance

terraspace: ## Terraspace is a terraform framework.
	${DOCKER_COMPOSE} --build terraspace

codebuild-local-set-up: ## Setting up CodeBuild Agent for testing buildspecs locally
	$(DOCKER) pull public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:5.0
	$(DOCKER) pull public.ecr.aws/codebuild/local-builds:latest
	$(CURL) -O https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh
	$(CHMOD) +x codebuild_build.sh

codebuild-run: ## Runnig CodeBuild for specific buildspec. Example: make codebuild-run buildspec='aws/buildspecs/website/buildspec_deploy.yml'
	./codebuild_build.sh -i $(image) -d -a codebuild_artifacts -b $(buildspec) -e .env

install-terraspace: ## Install terraspace locally.
	$(ECHO) "## Install OpenTofu"
	$(CURL) --proto "=https" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
	$(CHMOD) +x install-opentofu.sh
	./install-opentofu.sh --install-method rpm
	$(RM) install-opentofu.sh
	$(ECHO) "## Install Terraform"
	$(GIT) clone https://github.com/tfutils/tfenv.git ~/.tfenv
	$(ECHO) $(export PATH="$HOME/.tfenv/bin:$PATH") >>~/.bash_profile
	$(EXPORT) PATH="$HOME/.tfenv/bin:$PATH"
	$(TFENV) install 1.4.7
	$(TFENV) use 1.4.7
	$(BUNDLE) install --gemfile $(.TERRAFORM_DIR)/Gemfile

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

# Terraspace Output

terraspace-output: ## Output the stack variables. Variables: env, stack.
	$(EXEC_TS) output $(stack)

terraspace-output-file: ## Output the stack variables into file. Variables: env, stack, out.
	$(EXEC_TS) output $(stack) > $(out) -y

# Terraspace Down

terraspace-down: ## Down the stack. Variables: env, stack.
	$(EXEC_TS) down $(stack) -y
