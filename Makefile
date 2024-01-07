# Executables: local only
DOCKER_COMPOSE = docker compose -f docker/docker-compose.yml run --rm

# Misc
.DEFAULT_GOAL = help
.RECIPEPREFIX +=
.PHONY: $(filter-out vendor node_modules,$(MAKECMDGOALS))

help:
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

terraform: ## Terraform enables you to safely and predictably create, change, and improve infrastructure.
	${DOCKER_COMPOSE} terraform "$1"

terraform-compliance: ## Terraform compliance is a security and compliance focused test framework.
	${DOCKER_COMPOSE} terraform-compliance

terraspace: ## Terraspace is a terraform framework.
	${DOCKER_COMPOSE} --build terraspace
