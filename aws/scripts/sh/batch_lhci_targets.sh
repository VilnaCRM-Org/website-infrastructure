#!/bin/bash

# Lighthouse and Memory Leak Tests Batch Script
# Adds lighthouse-desktop, lighthouse-mobile, and test-memory-leak targets to Makefile

set -e

echo "#### Adding lighthouse and memory leak test targets to Makefile"

# Add all targets to Makefile using grouped redirects
{
cat << 'MEMORY_LEAK_TARGET'

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

MEMORY_LEAK_TARGET

cat << 'LIGHTHOUSE_DESKTOP_TARGET'

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

LIGHTHOUSE_DESKTOP_TARGET

cat << 'LIGHTHOUSE_MOBILE_TARGET'

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

LIGHTHOUSE_MOBILE_TARGET
} >> Makefile

echo "✅ Lighthouse and memory leak test targets added successfully" 