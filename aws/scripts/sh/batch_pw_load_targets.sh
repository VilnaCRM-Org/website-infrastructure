#!/bin/bash

# Playwright and Load Tests Batch Script
# Adds test-e2e, test-visual, test-visual-ui, test-visual-update, and load-tests targets to Makefile

set -e

echo "#### Adding Playwright and load test targets to Makefile"

# Add all targets to Makefile using grouped redirects
{
cat << 'E2E_TARGET'

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

E2E_TARGET

cat << 'VISUAL_TARGETS'

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

VISUAL_TARGETS

cat << 'LOAD_TARGET'

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
	@echo "📂 Copying K6 load test results..."
	@mkdir -p src/test/load/results
	@docker cp website-k6-temp:/loadTests/results/. src/test/load/results/ 2>/dev/null || echo "No load test results to copy"
	@echo "🧹 Cleaning up K6 container..."
	@docker rm -f website-k6-temp
	@echo "🎉 Load tests completed successfully in true DinD mode!"
	@echo "📊 Summary: K6 load testing completed with performance metrics"
else
	$(LOAD_TEST_CMD)
endif

LOAD_TARGET
} >> Makefile

echo "✅ Playwright and load test targets added successfully" 