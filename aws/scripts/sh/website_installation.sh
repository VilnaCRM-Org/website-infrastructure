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

echo #### Applying DinD modifications for CodeBuild environment

# Simple approach: directly override the test commands to run without docker-compose
# First, backup the original Makefile in case we need to debug
cp Makefile Makefile.backup

# Remove any existing test-unit-all target completely using a more robust approach
# Find the line number of test-unit-all and remove it and its dependencies
sed -i '/^test-unit-all:/,/^[a-zA-Z]/{ /^test-unit-all:/d; /^[[:space:]]/d; /^$/d; /^[a-zA-Z]/!d; }' Makefile

# Add our DinD variable at the top
if ! grep -q "DIND" Makefile; then
    sed -i '/^CI[[:space:]]*?= 0$/a DIND                        ?= 0' Makefile
fi

# Add a simple DinD-aware test-unit-all target
cat >> Makefile << 'EOF'

test-unit-all: ## Execute all unit tests with DinD support
ifeq ($(DIND), 1)
	@echo "🐳 Running unit tests in DinD mode (bypassing Docker Compose)"
	@echo "Running client-side tests..."
	TEST_ENV=client ./node_modules/.bin/jest --verbose
	@echo "Running server-side tests..."
	TEST_ENV=server ./node_modules/.bin/jest --verbose
	@echo "✅ All unit tests completed in DinD mode"
else
	@echo "🐳 Running unit tests with Docker Compose"
	make start && docker compose exec -T dev env TEST_ENV=client ./node_modules/.bin/jest --verbose
	make start && docker compose exec -T dev env TEST_ENV=server ./node_modules/.bin/jest --verbose
endif
EOF

echo "✅ DinD modifications applied successfully!"
echo "Modified Makefile to run tests directly in DinD mode"

# Debug: Show what was changed
echo "🔍 Verification - showing new test-unit-all target:"
grep -A10 "test-unit-all:" Makefile | tail -10