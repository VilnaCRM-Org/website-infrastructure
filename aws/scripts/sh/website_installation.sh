#!/bin/bash

# Install required packages using apk
apk add --no-cache \
    git \
    curl \
    nodejs \
    npm \
    make \
    sed \
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

echo #### Applying true DinD modifications for CodeBuild environment

# Backup original files
cp Makefile Makefile.backup
cp docker-compose.yml docker-compose.yml.backup

# Add DIND variable
if ! grep -q "DIND" Makefile; then
    sed -i '/^CI[[:space:]]*?= 0$/a DIND                        ?= 0' Makefile
fi

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

# Remove existing test-unit-all target
sed -i '/^test-unit-all:/,/^[a-zA-Z][a-zA-Z-]*:/{
    /^test-unit-all:/d
    /^[a-zA-Z][a-zA-Z-]*:/!d
}' Makefile

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
EOF
