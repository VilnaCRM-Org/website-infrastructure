#!/bin/bash

# Package Installation Script
# Installs required system packages using apk

set -e

echo "#### Installing Required Packages"

# Install required packages using apk
apk add --no-cache \
    bash \
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

echo "✅ All required packages installed successfully"
