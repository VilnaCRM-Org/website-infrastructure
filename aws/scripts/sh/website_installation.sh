#!/bin/bash

# Website Installation Script
# Handles git repository cloning and pnpm installation

set -e

echo "#### Website Installation and Setup"

# Clean up existing directory if it exists
if [ -d "$CODEBUILD_SRC_DIR/website" ]; then
    echo "Cleaning up existing website directory..."
    rm -rf "$CODEBUILD_SRC_DIR/website"
fi

# Clone the website repository
mkdir -p "$CODEBUILD_SRC_DIR"/website
git clone -b "$WEBSITE_GIT_REPOSITORY_BRANCH" "$WEBSITE_GIT_REPOSITORY_LINK.git" "$CODEBUILD_SRC_DIR"/website
cd "$CODEBUILD_SRC_DIR"/website/ || {
    echo "Error: Failed to change directory to website folder" >&2
    exit 1
}

echo "#### Installing pnpm"
npm install -g pnpm || {
    echo "Error: Failed to install pnpm" >&2
    exit 1
}

echo "✅ Website installation completed successfully" 