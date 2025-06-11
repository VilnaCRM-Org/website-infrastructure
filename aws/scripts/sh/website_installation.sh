#!/bin/bash

# Install required packages using apk
apk add --no-cache \
    git \
    curl \
    nodejs \
    npm \
    make \
    sed \
    docker-cli \
    docker-compose \
    || {
        echo "Error: Failed to install required packages" >&2
        exit 1
    }

echo #### Install Software
# Clean up existing directory if it exists
if [ -d "$CODEBUILD_SRC_DIR/website" ]; then
    echo "Cleaning up existing website directory..."
    rm -rf "$CODEBUILD_SRC_DIR/website"
fi

mkdir -p "$CODEBUILD_SRC_DIR"/website
git clone -b "$WEBSITE_GIT_REPOSITORY_BRANCH" "$WEBSITE_GIT_REPOSITORY_LINK.git" "$CODEBUILD_SRC_DIR"/website
cd "$CODEBUILD_SRC_DIR"/website/ || {
    echo "Error: Failed to change directory to website folder" >&2
    exit 1
}

echo #### Install pnpm
npm install -g pnpm || {
    echo "Error: Failed to install pnpm" >&2
    exit 1
}

echo #### Starting Docker daemon...
nohup /usr/local/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375 --storage-driver=overlay2 &
timeout 15 sh -c 'until docker info; do echo \"Waiting for Docker to start...\"; sleep 1; done'

echo #### Applying true DinD modifications for CodeBuild environment

# Add DIND variable
if ! grep -q "DIND" Makefile; then
    sed -i '/^CI[[:space:]]*?= 0$/a DIND                        ?= 0' Makefile
fi

# Modify Dockerfile to use latest package versions
echo "#### Modifying Dockerfile to use latest package versions..."
sed -i 's/python3=3.12.10-r1/python3/g' Dockerfile
sed -i 's/make=4.4.1-r2/make/g' Dockerfile
sed -i 's/g++=14.2.0-r4/g++/g' Dockerfile
sed -i 's/curl=8.12.1-r1/curl/g' Dockerfile

# Modify docker-compose.yml for true DinD networking
# Add container name for dev service
sed -i '/^  dev:$/a \    container_name: website-dev' docker-compose.yml

# Add networks section to dev service (before volumes section)
sed -i '/^    volumes:$/i \    networks:\n      - website-network' docker-compose.yml

# Add networks section at the end of the file
cat >> docker-compose.yml << 'EOF'

networks:
  website-network:
    external: true
    name: website-network
EOF

# Modify docker-compose.test.yml for true DinD networking
# Add container names and networks for test services
sed -i '/^  prod:$/a \    container_name: website-prod' docker-compose.test.yml
sed -i '/^  playwright:$/a \    container_name: website-playwright' docker-compose.test.yml
sed -i '/^  apollo:$/a \    container_name: website-apollo' docker-compose.test.yml
sed -i '/^  mockoon:$/a \    container_name: website-mockoon' docker-compose.test.yml
sed -i '/^  k6:$/a \    container_name: website-k6' docker-compose.test.yml
sed -i '/^    healthcheck:$/i \    networks:\n      - website-network' docker-compose.test.yml

# Add networks section at the end of test compose file
cat >> docker-compose.test.yml << 'EOF'

networks:
  website-network:
    external: true
    name: website-network
EOF

# Remove existing tests targets
for t in test-unit-all test-mutation lint-next lint-tsc lint-md test-e2e start-prod wait-for-prod test-visual test-visual-ui test-visual-update load-tests; do
  sed -i "/^${t}:/,/^[a-zA-Z][a-zA-Z-]*:/d" Makefile
done

# Add true DinD-aware targets
cat >> Makefile << 'EOF'

setup-dind-network: ## Create Docker network for DinD mode
	@echo "🐳 Setting up Docker network for DinD mode..."
	@docker network create website-network 2>/dev/null || echo "Network website-network already exists"

wait-for-dev-dind: ## Wait for dev service in DinD mode using container networking
	@echo "🐳 Waiting for dev service to be ready via Docker network..."
	@echo "Debug: Checking if container is running..."
	@for i in $$(seq 1 30); do \
		if docker ps --filter "name=website-dev" --filter "status=running" --format "{{.Names}}" | grep -q "website-dev"; then \
			echo "✅ Container website-dev is running"; \
			break; \
		fi; \
		echo "Attempt $$i: Container not running yet, waiting..."; \
		sleep 2; \
		if [ $$i -eq 30 ]; then \
			echo "❌ Container failed to start within 60 seconds"; \
			docker ps -a --filter "name=website-dev"; \
			exit 1; \
		fi; \
	done
	@echo "🔍 Testing container connectivity..."
	@for i in $$(seq 1 60); do \
		if docker exec website-dev sh -c "curl -f http://localhost:$(DEV_PORT)/api/health >/dev/null 2>&1 || curl -f http://127.0.0.1:$(DEV_PORT) >/dev/null 2>&1"; then \
			echo "✅ Dev service is responding on port $(DEV_PORT)!"; \
			break; \
		fi; \
		echo "Attempt $$i: Dev service not ready, checking container status..."; \
		if [ $$((i % 10)) -eq 0 ]; then \
			echo "Debug info at attempt $$i:"; \
			docker exec website-dev ps aux 2>/dev/null || echo "Cannot access container processes"; \
			docker exec website-dev netstat -tulpn 2>/dev/null | grep :$(DEV_PORT) || echo "Port $(DEV_PORT) not bound"; \
		fi; \
		sleep 3; \
		if [ $$i -eq 60 ]; then \
			echo "❌ Dev service failed to respond within 180 seconds"; \
			echo "Final container logs:"; \
			docker logs website-dev --tail 50; \
			exit 1; \
		fi; \
	done

start-dind: ## Start application in DinD mode with network setup
	@echo "🐳 Starting application in true DinD mode..."
	make setup-dind-network
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_DEV_FILE) up -d dev
	make wait-for-dev-dind

test-unit-all: ## Execute all unit tests in true DinD mode
ifeq ($(DIND), 1)
	@echo "🐳 Running unit tests in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building container image..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_DEV_FILE) build dev
	@echo "🧹 Cleaning up any existing temporary containers..."
	@docker rm -f website-dev-temp 2>/dev/null || true
	@echo "🛠️ Starting container in background for file operations..."
	docker run -d --name website-dev-temp --network website-network website-dev tail -f /dev/null
	@echo "📂 Copying source files into container..."
	@if docker cp . website-dev-temp:/app/; then \
		echo "✅ Source files copied successfully"; \
	else \
		echo "❌ Failed to copy source files"; \
		docker rm -f website-dev-temp; \
		exit 1; \
	fi
	@echo "📦 Installing dependencies inside container..."
	@if docker exec website-dev-temp sh -c "cd /app && npm install -g pnpm && pnpm install --frozen-lockfile"; then \
		echo "✅ Dependencies installed successfully"; \
	else \
		echo "❌ Failed to install dependencies"; \
		docker logs website-dev-temp --tail 20; \
		docker rm -f website-dev-temp; \
		exit 1; \
	fi
	@echo "🧪 Running client-side tests..."
	@if docker exec website-dev-temp sh -c "cd /app && env TEST_ENV=client ./node_modules/.bin/jest --verbose --passWithNoTests --maxWorkers=2"; then \
		echo "✅ Client-side tests PASSED"; \
	else \
		echo "❌ Client-side tests FAILED"; \
		docker logs website-dev-temp --tail 30; \
		docker rm -f website-dev-temp; \
		exit 1; \
	fi
	@echo "🧪 Running server-side tests..."
	@if docker exec website-dev-temp sh -c "cd /app && env TEST_ENV=server ./node_modules/.bin/jest --verbose --passWithNoTests --maxWorkers=2"; then \
		echo "✅ Server-side tests PASSED"; \
	else \
		echo "❌ Server-side tests FAILED"; \
		docker logs website-dev-temp --tail 30; \
		docker rm -f website-dev-temp; \
		exit 1; \
	fi
	@echo "🧹 Cleaning up temporary container..."
	@docker rm -f website-dev-temp
	@echo "🎉 All unit tests completed successfully in true DinD mode!"
	@echo "📊 Summary: Both client and server tests passed in containerized environment"
else
	@echo "🐳 Running unit tests with standard Docker Compose"
	$(UNIT_TESTS) TEST_ENV=client $(JEST_BIN) $(JEST_FLAGS)
	$(UNIT_TESTS) TEST_ENV=server $(JEST_BIN) $(JEST_FLAGS) $(TEST_DIR_APOLLO)
endif

test-memory-leak: ## Execute memory leak tests in true DinD mode using Memlab
ifeq ($(DIND), 1)
	@echo "🐳 Running memory leak tests in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "🧹 Cleaning up any existing containers..."
	@docker rm -f website-prod website-memory-leak-temp 2>/dev/null || true
	@echo "🏗️ Building production environment for memory leak testing..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) build
	@echo "🚀 Starting production services in background..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) up -d
	@echo "⏳ Waiting for production services to be ready..."
	@for i in $$(seq 1 60); do \
		if docker ps --filter "name=website-prod" --filter "status=running" --format "{{.Names}}" | grep -q "website-prod"; then \
			if docker exec website-prod sh -c "curl -f http://localhost:$(NEXT_PUBLIC_PROD_PORT) >/dev/null 2>&1"; then \
				echo "✅ Production service is ready on port $(NEXT_PUBLIC_PROD_PORT)!"; \
				break; \
			fi; \
		fi; \
		echo "Attempt $$i: Production service not ready yet..."; \
		if [ $$((i % 15)) -eq 0 ]; then \
			echo "Debug info at attempt $$i:"; \
			docker ps --filter "name=website-prod" || echo "No prod containers found"; \
		fi; \
		sleep 3; \
		if [ $$i -eq 60 ]; then \
			echo "❌ Production service failed to start within 180 seconds"; \
			docker logs website-prod --tail 50 2>/dev/null || echo "Cannot get prod logs"; \
			exit 1; \
		fi; \
	done
	@echo "🧪 Building memory leak test container..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_MEMLEAK_FILE) build memory-leak
	@echo "🛠️ Starting memory leak test container..."
	docker run -d --name website-memory-leak-temp --network website-network --env NEXT_PUBLIC_PROD_CONTAINER_API_URL=http://website-prod:$(NEXT_PUBLIC_PROD_PORT) --env MEMLAB_DEBUG=true --env MEMLAB_SKIP_WARMUP=true --env DISPLAY=:99 --shm-size=1gb website-memory-leak tail -f /dev/null
	@echo "📂 Copying source files into memory leak container..."
	@if docker cp src/test/memory-leak/. website-memory-leak-temp:/app/src/test/memory-leak/; then \
		echo "✅ Memory leak test files copied successfully"; \
	else \
		echo "❌ Failed to copy memory leak test files"; \
		docker rm -f website-memory-leak-temp; \
		exit 1; \
	fi
	@echo "📂 Copying required config files..."
	@docker cp src/config/i18nConfig.js website-memory-leak-temp:/app/src/config/ 2>/dev/null || echo "Config file not found"
	@docker cp pages/i18n/localization.json website-memory-leak-temp:/app/pages/i18n/ 2>/dev/null || echo "Localization file not found"
	@echo "🧹 Cleaning up previous memory leak results..."
	@docker exec website-memory-leak-temp sh -c "rm -rf /app/src/test/memory-leak/results"
	@echo "🧠 Running Memlab memory leak tests..."
	@if docker exec website-memory-leak-temp sh -c "cd /app && node src/test/memory-leak/runMemlabTests.js"; then \
		echo "✅ Memory leak tests PASSED"; \
	else \
		echo "❌ Memory leak tests FAILED"; \
		docker logs website-memory-leak-temp --tail 30; \
		docker rm -f website-memory-leak-temp; \
		exit 1; \
	fi
	@echo "📂 Copying memory leak test results..."
	@mkdir -p memory-leak-results
	@docker cp website-memory-leak-temp:/app/src/test/memory-leak/results/. memory-leak-results/ 2>/dev/null || echo "No memory leak results to copy"
	@echo "🧹 Cleaning up memory leak test container..."
	@docker rm -f website-memory-leak-temp
	@echo "🎉 Memory leak tests completed successfully in true DinD mode!"
	@echo "📊 Summary: Memory leak analysis completed using Memlab in containerized environment"
else
	@echo "🐳 Running memory leak tests with standard Docker Compose"
	@echo "🧪 Starting memory leak test environment..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_MEMLEAK_FILE) up -d
	@echo "🧹 Cleaning up previous memory leak results..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_MEMLEAK_FILE) exec -T $(MEMLEAK_SERVICE) rm -rf $(MEMLEAK_RESULTS_DIR)
	@echo "🚀 Running memory leak tests..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_MEMLEAK_FILE) exec -T $(MEMLEAK_SERVICE) node $(MEMLEAK_TEST_SCRIPT)
endif

test-mutation: build ## Run mutation tests using Stryker in true DinD mode
ifeq ($(DIND), 1)
	@echo "🐳 Running mutation tests in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building container image..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_DEV_FILE) build dev
	@echo "🧹 Cleaning up any existing containers..."
	@docker rm -f website-dev-mutation 2>/dev/null || true
	@echo "🛠️ Starting container in background for file operations..."
	docker run -d --name website-dev-mutation --network website-network website-dev tail -f /dev/null
	@echo "📂 Copying source files into container..."
	@if docker cp . website-dev-mutation:/app/; then \
		echo "✅ Source files copied successfully"; \
	else \
		echo "❌ Failed to copy source files"; \
		docker rm -f website-dev-mutation; \
		exit 1; \
	fi
	@echo "📦 Installing dependencies inside container..."
	@if docker exec website-dev-mutation sh -c "cd /app && npm install -g pnpm && pnpm install --frozen-lockfile"; then \
		echo "✅ Dependencies installed successfully"; \
	else \
		echo "❌ Failed to install dependencies"; \
		docker logs website-dev-mutation --tail 20; \
		docker rm -f website-dev-mutation; \
		exit 1; \
	fi
	@echo "🚀 Starting dev server in background..."
	@docker exec -d website-dev-mutation sh -c "cd /app && ./node_modules/.bin/next dev"
	@echo "⏳ Waiting for dev server to be ready..."
	@for i in $$(seq 1 60); do \
		if docker exec website-dev-mutation sh -c "curl -f http://localhost:3000 >/dev/null 2>&1"; then \
			echo "✅ Dev server is responding on port 3000!"; \
			break; \
		fi; \
		echo "Attempt $$i: Dev server not ready yet..."; \
		if [ $$((i % 10)) -eq 0 ]; then \
			echo "Debug info at attempt $$i:"; \
			docker exec website-dev-mutation ps aux 2>/dev/null | grep -E "(next|node)" || echo "No Next.js processes found"; \
			docker exec website-dev-mutation netstat -tulpn 2>/dev/null | grep :3000 || echo "Port 3000 not bound"; \
			echo "Recent container logs:"; \
			docker logs website-dev-mutation --tail 10; \
		fi; \
		sleep 3; \
		if [ $$i -eq 60 ]; then \
			echo "❌ Dev server failed to respond within 180 seconds"; \
			docker logs website-dev-mutation --tail 50; \
			docker rm -f website-dev-mutation; \
			exit 1; \
		fi; \
	done
	@echo "🧬 Running Stryker mutation tests..."
	@if docker exec website-dev-mutation sh -c "cd /app && pnpm stryker run"; then \
		echo "✅ Mutation tests PASSED"; \
	else \
		echo "❌ Mutation tests FAILED"; \
		docker logs website-dev-mutation --tail 30; \
		docker rm -f website-dev-mutation; \
		exit 1; \
	fi
	@echo "📂 Copying mutation reports..."
	@mkdir -p reports/mutation
	@docker cp website-dev-mutation:/app/reports/mutation/. reports/mutation/ 2>/dev/null || echo "No mutation reports to copy"
	@echo "🧹 Cleaning up mutation container..."
	@docker rm -f website-dev-mutation
	@echo "🎉 Mutation tests completed successfully in true DinD mode!"
else
	@echo "🐳 Running mutation tests with standard Docker Compose"
	$(STRYKER_CMD)
endif

lint-next: ## This command executes ESLint
ifeq ($(DIND), 1)
	@echo "🐳 Running ESLint in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building container image..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_DEV_FILE) build dev
	@echo "🧹 Cleaning up any existing containers..."
	@docker rm -f website-dev-lint-next 2>/dev/null || true
	@echo "🛠️ Starting container for linting..."
	docker run -d --name website-dev-lint-next --network website-network website-dev tail -f /dev/null
	@echo "📂 Copying source files into container..."
	@if docker cp . website-dev-lint-next:/app/; then \
		echo "✅ Source files copied successfully"; \
	else \
		echo "❌ Failed to copy source files"; \
		docker rm -f website-dev-lint-next; \
		exit 1; \
	fi
	@echo "📦 Installing dependencies inside container..."
	@if docker exec website-dev-lint-next sh -c "cd /app && npm install -g pnpm && pnpm install --frozen-lockfile"; then \
		echo "✅ Dependencies installed successfully"; \
	else \
		echo "❌ Failed to install dependencies"; \
		docker logs website-dev-lint-next --tail 20; \
		docker rm -f website-dev-lint-next; \
		exit 1; \
	fi
	@echo "🔍 Running ESLint..."
	@if docker exec website-dev-lint-next sh -c "cd /app && ./node_modules/.bin/next lint"; then \
		echo "✅ ESLint check PASSED"; \
	else \
		echo "❌ ESLint check FAILED"; \
		docker logs website-dev-lint-next --tail 30; \
		docker rm -f website-dev-lint-next; \
		exit 1; \
	fi
	@echo "🧹 Cleaning up lint container..."
	@docker rm -f website-dev-lint-next
	@echo "🎉 ESLint completed successfully in true DinD mode!"
else
	$(PNPM_EXEC) $(NEXT_BIN) lint
endif

lint-tsc: ## This command executes Typescript linter
ifeq ($(DIND), 1)
	@echo "🐳 Running TypeScript check in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building container image..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_DEV_FILE) build dev
	@echo "🧹 Cleaning up any existing containers..."
	@docker rm -f website-dev-lint-tsc 2>/dev/null || true
	@echo "🛠️ Starting container for TypeScript checking..."
	docker run -d --name website-dev-lint-tsc --network website-network website-dev tail -f /dev/null
	@echo "📂 Copying source files into container..."
	@if docker cp . website-dev-lint-tsc:/app/; then \
		echo "✅ Source files copied successfully"; \
	else \
		echo "❌ Failed to copy source files"; \
		docker rm -f website-dev-lint-tsc; \
		exit 1; \
	fi
	@echo "📦 Installing dependencies inside container..."
	@if docker exec website-dev-lint-tsc sh -c "cd /app && npm install -g pnpm && pnpm install --frozen-lockfile"; then \
		echo "✅ Dependencies installed successfully"; \
	else \
		echo "❌ Failed to install dependencies"; \
		docker logs website-dev-lint-tsc --tail 20; \
		docker rm -f website-dev-lint-tsc; \
		exit 1; \
	fi
	@echo "🔍 Running TypeScript check..."
	@if docker exec website-dev-lint-tsc sh -c "cd /app && ./node_modules/.bin/tsc"; then \
		echo "✅ TypeScript check PASSED"; \
	else \
		echo "❌ TypeScript check FAILED"; \
		docker logs website-dev-lint-tsc --tail 30; \
		docker rm -f website-dev-lint-tsc; \
		exit 1; \
	fi
	@echo "🧹 Cleaning up lint container..."
	@docker rm -f website-dev-lint-tsc
	@echo "🎉 TypeScript check completed successfully in true DinD mode!"
else
	$(PNPM_EXEC) $(TS_BIN)
endif

lint-md: ## This command executes Markdown linter
ifeq ($(DIND), 1)
	@echo "🐳 Running Markdown lint in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building container image..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_DEV_FILE) build dev
	@echo "🧹 Cleaning up any existing containers..."
	@docker rm -f website-dev-lint-md 2>/dev/null || true
	@echo "🛠️ Starting container for Markdown linting..."
	docker run -d --name website-dev-lint-md --network website-network website-dev tail -f /dev/null
	@echo "📂 Copying source files into container..."
	@if docker cp . website-dev-lint-md:/app/; then \
		echo "✅ Source files copied successfully"; \
	else \
		echo "❌ Failed to copy source files"; \
		docker rm -f website-dev-lint-md; \
		exit 1; \
	fi
	@echo "📦 Installing dependencies inside container..."
	@if docker exec website-dev-lint-md sh -c "cd /app && npm install -g pnpm && pnpm install --frozen-lockfile"; then \
		echo "✅ Dependencies installed successfully"; \
	else \
		echo "❌ Failed to install dependencies"; \
		docker logs website-dev-lint-md --tail 20; \
		docker rm -f website-dev-lint-md; \
		exit 1; \
	fi
	@echo "🔍 Running Markdown lint..."
	@if docker exec website-dev-lint-md sh -c "cd /app && ./node_modules/.bin/markdownlint -i CHANGELOG.md -i \"test-results/**/*.md\" -i \"playwright-report/data/**/*.md\" \"**/*.md\""; then \
		echo "✅ Markdown lint PASSED"; \
	else \
		echo "❌ Markdown lint FAILED"; \
		docker logs website-dev-lint-md --tail 30; \
		docker rm -f website-dev-lint-md; \
		exit 1; \
	fi
	@echo "🧹 Cleaning up lint container..."
	@docker rm -f website-dev-lint-md
	@echo "🎉 Markdown lint completed successfully in true DinD mode!"
else
	$(MARKDOWNLINT_BIN) $(MD_LINT_ARGS) "**/*.md"
endif

start-prod: ## Build image and start container in production mode
ifeq ($(DIND), 1)
	@echo "🐳 Starting production environment in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building production container image..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) build
	@echo "🚀 Starting production services..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) up -d
	make wait-for-prod
else
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) up -d && make wait-for-prod
endif

wait-for-prod: ## Wait for the prod service to be ready on port $(NEXT_PUBLIC_PROD_PORT).
ifeq ($(DIND), 1)
	@echo "🐳 Waiting for prod service in true DinD mode using container networking..."
	@echo "Checking if prod container is running..."
	@for i in $$(seq 1 30); do \
		if docker ps --filter "name=website-prod" --filter "status=running" --format "{{.Names}}" | grep -q "website-prod"; then \
			echo "✅ Container website-prod is running"; \
			break; \
		fi; \
		echo "Attempt $$i: Container not running yet, waiting..."; \
		sleep 2; \
		if [ $$i -eq 30 ]; then \
			echo "❌ Container failed to start within 60 seconds"; \
			docker ps -a --filter "name=website-prod"; \
			exit 1; \
		fi; \
	done
	@echo "🔍 Testing prod service connectivity..."
	@for i in $$(seq 1 60); do \
		if docker exec website-prod sh -c "curl -f http://localhost:$(NEXT_PUBLIC_PROD_PORT) >/dev/null 2>&1"; then \
			echo "✅ Prod service is responding on port $(NEXT_PUBLIC_PROD_PORT)!"; \
			break; \
		fi; \
		echo "Attempt $$i: Prod service not ready, checking container status..."; \
		if [ $$((i % 10)) -eq 0 ]; then \
			echo "Debug info at attempt $$i:"; \
			docker exec website-prod ps aux 2>/dev/null || echo "Cannot access container processes"; \
			docker exec website-prod netstat -tulpn 2>/dev/null | grep :$(NEXT_PUBLIC_PROD_PORT) || echo "Port $(NEXT_PUBLIC_PROD_PORT) not bound"; \
		fi; \
		sleep 3; \
		if [ $$i -eq 60 ]; then \
			echo "❌ Prod service failed to respond within 180 seconds"; \
			echo "Final container logs:"; \
			docker logs website-prod --tail 50; \
			exit 1; \
		fi; \
	done
else
	@echo "Waiting for prod service to be ready on port $(NEXT_PUBLIC_PROD_PORT)..."
	npx wait-on -v http://$(WEBSITE_DOMAIN):$(NEXT_PUBLIC_PROD_PORT)
	@echo "Prod service is up and running!"
endif

test-e2e: start-prod ## Start production and run E2E tests (Playwright)
ifeq ($(DIND), 1)
	@echo "🐳 Running E2E tests in true Docker-in-Docker mode"
	@echo "Checking if Playwright container is available..."
	@for i in $$(seq 1 30); do \
		if docker ps --filter "name=website-playwright" --filter "status=running" --format "{{.Names}}" | grep -q "website-playwright"; then \
			echo "✅ Playwright container is running"; \
			break; \
		fi; \
		echo "Attempt $$i: Playwright container not running yet, waiting..."; \
		sleep 2; \
		if [ $$i -eq 30 ]; then \
			echo "❌ Playwright container failed to start within 60 seconds"; \
			docker ps -a --filter "name=website-playwright"; \
			exit 1; \
		fi; \
	done
	@echo "🧪 Running Playwright E2E tests..."
	@mkdir -p playwright-e2e-reports
	@echo "📂 Copying source code to Playwright container..."
	@docker cp . website-playwright:/app || echo "Warning: Failed to copy source code"
	@echo "🔍 Debugging: Verifying source code copy..."
	@docker exec website-playwright sh -c "ls -la /app && ls -la /app/src/test/e2e | head -5" || true
	@if docker exec website-playwright sh -c "cd /app && npx playwright test src/test/e2e --reporter=html"; then \
		echo "✅ E2E tests PASSED"; \
	else \
		echo "❌ E2E tests FAILED"; \
		echo "🔍 Debugging: Checking Playwright install and test files..."; \
		docker exec website-playwright sh -c "npx playwright --version && find /app -name '*.spec.ts' | head -5" || true; \
		exit 1; \
	fi
	@echo "📂 Copying E2E test reports..."
	@docker cp website-playwright:/app/playwright-report/. playwright-e2e-reports/ 2>/dev/null || echo "No E2E reports to copy"
	@echo "🎉 E2E tests completed successfully in true DinD mode!"
else
	$(run-e2e)
endif

test-visual: start-prod ## Start production and run visual tests (Playwright)
ifeq ($(DIND), 1)
	@echo "🐳 Running Visual tests in true Docker-in-Docker mode"
	@echo "Checking if Playwright container is available..."
	@for i in $$(seq 1 30); do \
		if docker ps --filter "name=website-playwright" --filter "status=running" --format "{{.Names}}" | grep -q "website-playwright"; then \
			echo "✅ Playwright container is running"; \
			break; \
		fi; \
		echo "Attempt $$i: Playwright container not running yet, waiting..."; \
		sleep 2; \
		if [ $$i -eq 30 ]; then \
			echo "❌ Playwright container failed to start within 60 seconds"; \
			docker ps -a --filter "name=website-playwright"; \
			exit 1; \
		fi; \
	done
	@echo "🎨 Running Playwright Visual tests..."
	@mkdir -p playwright-visual-reports
	@echo "📂 Copying source code to Playwright container..."
	@docker cp . website-playwright:/app || echo "Warning: Failed to copy source code"
	@echo "🔍 Debugging: Verifying source code copy..."
	@docker exec website-playwright sh -c "ls -la /app && ls -la /app/src/test/visual | head -5" || true
	@if docker exec website-playwright sh -c "cd /app && npx playwright test src/test/visual --reporter=html --timeout=5000"; then \
		echo "✅ Visual tests PASSED"; \
	else \
		echo "❌ Visual tests FAILED"; \
		echo "🔍 Debugging: Checking Playwright install and test files..."; \
		docker exec website-playwright sh -c "npx playwright --version && find /app -path '*/visual/*.spec.ts' | head -5" || true; \
		exit 1; \
	fi
	@echo "📂 Copying Visual test reports..."
	@docker cp website-playwright:/app/playwright-report/. playwright-visual-reports/ 2>/dev/null || echo "No Visual reports to copy"
	@echo "🎉 Visual tests completed successfully in true DinD mode!"
else
	$(run-visual)
endif

test-visual-ui: start-prod ## Start the production environment and run visual tests with the UI available
ifeq ($(DIND), 1)
	@echo "🐳 Running Visual tests with UI in true Docker-in-Docker mode"
	@echo "⚠️  Note: UI mode not fully supported in DinD environment"
	@echo "Checking if Playwright container is available..."
	@for i in $$(seq 1 30); do \
		if docker ps --filter "name=website-playwright" --filter "status=running" --format "{{.Names}}" | grep -q "website-playwright"; then \
			echo "✅ Playwright container is running"; \
			break; \
		fi; \
		echo "Attempt $$i: Playwright container not running yet, waiting..."; \
		sleep 2; \
		if [ $$i -eq 30 ]; then \
			echo "❌ Playwright container failed to start within 60 seconds"; \
			docker ps -a --filter "name=website-playwright"; \
			exit 1; \
		fi; \
	done
	@echo "🎨 Running Playwright Visual tests with UI mode..."
	@mkdir -p playwright-visual-reports
	@echo "📂 Copying source code to Playwright container..."
	@docker cp . website-playwright:/app || echo "Warning: Failed to copy source code"
	@if docker exec website-playwright sh -c "cd /app && npx playwright test src/test/visual --ui-port=9324 --ui-host=0.0.0.0 --reporter=html --timeout=15000"; then \
		echo "✅ Visual UI tests PASSED"; \
	else \
		echo "❌ Visual UI tests FAILED"; \
		exit 1; \
	fi
	@echo "📂 Copying Visual test reports..."
	@docker cp website-playwright:/app/playwright-report/. playwright-visual-reports/ 2>/dev/null || echo "No Visual reports to copy"
	@echo "🎉 Visual UI tests completed successfully in true DinD mode!"
else
	@echo "🚀 Starting Playwright UI tests..."
	@echo "Test will be run on: $(UI_MODE_URL)"
	$(playwright-test) $(TEST_DIR_VISUAL) $(UI_FLAGS)
endif

test-visual-update: start-prod ## Update Playwright visual snapshots
ifeq ($(DIND), 1)
	@echo "🐳 Updating Visual snapshots in true Docker-in-Docker mode"
	@echo "Checking if Playwright container is available..."
	@for i in $$(seq 1 30); do \
		if docker ps --filter "name=website-playwright" --filter "status=running" --format "{{.Names}}" | grep -q "website-playwright"; then \
			echo "✅ Playwright container is running"; \
			break; \
		fi; \
		echo "Attempt $$i: Playwright container not running yet, waiting..."; \
		sleep 2; \
		if [ $$i -eq 30 ]; then \
			echo "❌ Playwright container failed to start within 60 seconds"; \
			docker ps -a --filter "name=website-playwright"; \
			exit 1; \
		fi; \
	done
	@echo "📸 Updating Playwright Visual snapshots..."
	@echo "📂 Copying source code to Playwright container..."
	@docker cp . website-playwright:/app || echo "Warning: Failed to copy source code"
	@if docker exec website-playwright sh -c "cd /app && npx playwright test src/test/visual --update-snapshots --timeout=15000"; then \
		echo "✅ Visual snapshots updated successfully"; \
	else \
		echo "❌ Visual snapshot update FAILED"; \
		exit 1; \
	fi
	@echo "📂 Copying updated snapshots back..."
	@docker cp website-playwright:/app/src/test/visual/. src/test/visual/ 2>/dev/null || echo "No snapshots to copy back"
	@echo "🎉 Visual snapshots updated successfully in true DinD mode!"
else
	$(playwright-test) $(TEST_DIR_VISUAL) --update-snapshots
endif

lighthouse-desktop: ## Run a Lighthouse audit using desktop viewport settings to evaluate performance and best practices
ifeq ($(DIND), 1)
	@echo "🐳 Running Lighthouse Desktop audit in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building production environment for lighthouse..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) build
	@echo "📝 Creating temporary docker-compose override with memory settings for Chrome..."
	@printf 'services:\n  prod:\n    mem_limit: 2g\n    mem_reservation: 1g\n    shm_size: 2gb\n' > docker-compose.memory-override.yml
	@echo "🚀 Starting production services with increased memory..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) -f docker-compose.memory-override.yml up -d
	@rm -f docker-compose.memory-override.yml
	@echo "⏳ Waiting for production services to be ready..."
	@for i in $$(seq 1 60); do \
		if docker ps --filter "name=website-prod" --filter "status=running" --format "{{.Names}}" | grep -q "website-prod"; then \
			if docker exec website-prod sh -c "curl -f http://localhost:$(NEXT_PUBLIC_PROD_PORT) >/dev/null 2>&1"; then \
				echo "✅ Production service is ready on port $(NEXT_PUBLIC_PROD_PORT)!"; \
				break; \
			fi; \
		fi; \
		echo "Attempt $$i: Production service not ready yet..."; \
		sleep 3; \
		if [ $$i -eq 60 ]; then \
			echo "❌ Production service failed to start within 180 seconds"; \
			exit 1; \
		fi; \
	done
	@echo "📦 Installing Chrome and Lighthouse CLI in container..."
	@if docker exec website-prod sh -c "apk add --no-cache chromium chromium-chromedriver && npm install -g @lhci/cli@0.14.0"; then \
		echo "✅ Chrome and Lighthouse CLI installed successfully"; \
	else \
		echo "❌ Failed to install Chrome and Lighthouse CLI"; \
		exit 1; \
	fi
	@echo "📂 Copying Lighthouse config files..."
	@if docker cp lighthouserc.desktop.js website-prod:/app/; then \
		echo "✅ Lighthouse config files copied successfully"; \
	else \
		echo "❌ Failed to copy Lighthouse config files"; \
		exit 1; \
	fi
	@echo "🧪 Testing Chrome installation..."
	@if docker exec website-prod /usr/bin/chromium-browser --version; then \
		echo "✅ Chrome is installed and working"; \
	else \
		echo "❌ Chrome installation test failed"; \
		exit 1; \
	fi
	@echo "🧪 Testing Chrome headless mode..."
	@if docker exec website-prod timeout 10 /usr/bin/chromium-browser --headless --no-sandbox --disable-dev-shm-usage --disable-gpu --virtual-time-budget=1000 --dump-dom http://localhost:$(NEXT_PUBLIC_PROD_PORT); then \
		echo "✅ Chrome headless mode works"; \
	else \
		echo "❌ Chrome headless mode failed"; \
	fi
	@echo "🏃 Running Lighthouse Desktop audit..."
	@if docker exec -w /app website-prod lhci autorun --config=lighthouserc.desktop.js --collect.url=http://localhost:$(NEXT_PUBLIC_PROD_PORT) --collect.chromePath=/usr/bin/chromium-browser --collect.chromeFlags="--no-sandbox --disable-dev-shm-usage --disable-extensions --disable-gpu --headless --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding"; then \
		echo "✅ Lighthouse Desktop audit PASSED"; \
	else \
		echo "❌ Lighthouse Desktop audit FAILED"; \
		docker logs website-prod --tail 30; \
		exit 1; \
	fi
	@echo "📂 Copying lighthouse results..."
	@mkdir -p lhci-reports-desktop
	@docker cp website-prod:/app/lhci-reports-desktop/. lhci-reports-desktop/ 2>/dev/null || echo "No lighthouse desktop results to copy"
	@echo "🎉 Lighthouse Desktop audit completed successfully in true DinD mode!"
else
	$(LHCI_DESKTOP)
endif

lighthouse-mobile: ## Run a Lighthouse audit using mobile viewport settings to evaluate mobile UX and performance  
ifeq ($(DIND), 1)
	@echo "🐳 Running Lighthouse Mobile audit in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building production environment for lighthouse..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) build
	@echo "📝 Creating temporary docker-compose override with memory settings for Chrome..."
	@printf 'services:\n  prod:\n    mem_limit: 2g\n    mem_reservation: 1g\n    shm_size: 2gb\n' > docker-compose.memory-override.yml
	@echo "🚀 Starting production services with increased memory..."
	$(DOCKER_COMPOSE) $(COMMON_HEALTHCHECKS_FILE) $(DOCKER_COMPOSE_TEST_FILE) -f docker-compose.memory-override.yml up -d
	@rm -f docker-compose.memory-override.yml
	@echo "⏳ Waiting for production services to be ready..."
	@for i in $$(seq 1 60); do \
		if docker ps --filter "name=website-prod" --filter "status=running" --format "{{.Names}}" | grep -q "website-prod"; then \
			if docker exec website-prod sh -c "curl -f http://localhost:$(NEXT_PUBLIC_PROD_PORT) >/dev/null 2>&1"; then \
				echo "✅ Production service is ready on port $(NEXT_PUBLIC_PROD_PORT)!"; \
				break; \
			fi; \
		fi; \
		echo "Attempt $$i: Production service not ready yet..."; \
		sleep 3; \
		if [ $$i -eq 60 ]; then \
			echo "❌ Production service failed to start within 180 seconds"; \
			exit 1; \
		fi; \
	done
	@echo "📦 Installing Chrome and Lighthouse CLI in container..."
	@if docker exec website-prod sh -c "apk add --no-cache chromium chromium-chromedriver && npm install -g @lhci/cli@0.14.0"; then \
		echo "✅ Chrome and Lighthouse CLI installed successfully"; \
	else \
		echo "❌ Failed to install Chrome and Lighthouse CLI"; \
		exit 1; \
	fi
	@echo "📂 Copying Lighthouse config files..."
	@if docker cp lighthouserc.mobile.js website-prod:/app/; then \
		echo "✅ Lighthouse config files copied successfully"; \
	else \
		echo "❌ Failed to copy Lighthouse config files"; \
		exit 1; \
	fi
	@echo "🏃 Running Lighthouse Mobile audit..."
	@if docker exec -w /app website-prod lhci autorun --config=lighthouserc.mobile.js --collect.url=http://localhost:$(NEXT_PUBLIC_PROD_PORT) --collect.chromePath=/usr/bin/chromium-browser --collect.chromeFlags="--no-sandbox --disable-dev-shm-usage --disable-extensions --disable-gpu --headless --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding"; then \
		echo "✅ Lighthouse Mobile audit PASSED"; \
	else \
		echo "❌ Lighthouse Mobile audit FAILED"; \
		docker logs website-prod --tail 30; \
		exit 1; \
	fi
	@echo "📂 Copying lighthouse results..."
	@mkdir -p lhci-reports-mobile
	@docker cp website-prod:/app/lhci-reports-mobile/. lhci-reports-mobile/ 2>/dev/null || echo "No lighthouse mobile results to copy"
	@echo "🎉 Lighthouse Mobile audit completed successfully in true DinD mode!"
else
	$(LHCI_MOBILE)
endif

load-tests: start-prod wait-for-prod-health ## This command executes load tests using K6 library in DinD mode
ifeq ($(DIND), 1)
	@echo "🐳 Running Load tests in true Docker-in-Docker mode"
	@echo "Setting up Docker network..."
	make setup-dind-network
	@echo "Building k6 container image..."
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_TEST_FILE) --profile load build k6
	@echo "🧹 Cleaning up any existing k6 containers..."
	@docker rm -f website-k6-temp 2>/dev/null || true
	@echo "📂 Creating results directory..."
	@mkdir -p src/test/load/results
	@echo "🛠️ Starting k6 container in background for file operations..."
	@docker run -d --name website-k6-temp --network website-network --entrypoint=/bin/sh website-k6 -c "while true; do sleep 60; done"
	@echo "📂 Copying load test files into k6 container..."
	@if docker cp src/test/load/. website-k6-temp:/loadTests/; then \
		echo "✅ Load test files copied successfully"; \
	else \
		echo "❌ Failed to copy load test files"; \
		docker rm -f website-k6-temp; \
		exit 1; \
	fi
	@echo "📂 Verifying load test files..."
	@docker exec website-k6-temp /bin/sh -c "ls -la /loadTests/ && head -5 /loadTests/homepage.js"
	@echo "🚀 Running K6 load tests..."
	@if docker exec -w /loadTests website-k6-temp /bin/k6 run --summary-trend-stats='avg,min,med,max,p(95),p(99)' --out 'web-dashboard=period=1s&export=/loadTests/results/homepage.html' homepage.js; then \
		echo "✅ Load tests PASSED"; \
	else \
		echo "❌ Load tests FAILED"; \
		docker logs website-k6-temp --tail 30; \
		docker rm -f website-k6-temp; \
		exit 1; \
	fi
	@echo "📂 Copying load test results back..."
	@docker cp website-k6-temp:/loadTests/results/. src/test/load/results/ 2>/dev/null || echo "No load test results to copy"
	@echo "🧹 Cleaning up k6 container..."
	@docker rm -f website-k6-temp
	@echo "🎉 Load tests completed successfully in true DinD mode!"
else
	$(LOAD_TESTS_RUN)
endif
EOF
