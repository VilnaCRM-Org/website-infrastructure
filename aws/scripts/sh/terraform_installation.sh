#!/bin/bash

# terraform_installation.sh
#
# Purpose: Sets up infrastructure management tools for sandbox environments
# Context: Part of the CI/CD pipeline for deploying sandbox infrastructure
# Requirements:
#   - AWS CodeBuild environment
#   - Ruby for Terraform testing
#   - RPM package manager

echo "## Install OpenTofu"
if ! curl --proto "=https" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh; then
    echo "Failed to download OpenTofu installation script"
    exit 1
fi
chmod +x install-opentofu.sh
if ! ./install-opentofu.sh --install-method rpm; then
    echo "OpenTofu installation failed"
    rm install-opentofu.sh
    exit 1
fi
rm install-opentofu.sh

echo "## Install Terraform"
TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.10.5}"
if ! git clone https://github.com/tfutils/tfenv.git ~/.tfenv; then
    echo "Failed to clone tfenv repository"
    exit 1
fi

if ! echo "export PATH=\"$HOME/.tfenv/bin:\$PATH\"" >>~/.bash_profile; then
    echo "Failed to update PATH in .bash_profile"
    exit 1
fi
export PATH="$HOME/.tfenv/bin:$PATH"

tfenv install "${TERRAFORM_VERSION}" || { echo "Failed to install Terraform ${TERRAFORM_VERSION}"; exit 1; }
tfenv use "${TERRAFORM_VERSION}" || { echo "Failed to switch to Terraform ${TERRAFORM_VERSION}"; exit 1; }

GEMFILE_PATH="${CODEBUILD_SRC_DIR}/terraform/Gemfile"
if [ ! -f "$GEMFILE_PATH" ]; then
    echo "Gemfile not found at: $GEMFILE_PATH"
    exit 1
fi

if [ ! -f "${GEMFILE_PATH}.lock" ]; then
    echo "Warning: Gemfile.lock not found. This may lead to inconsistent dependencies."
fi

echo "Installing Ruby dependencies..."
if ! bundle install --gemfile "$GEMFILE_PATH"; then
    echo "Failed to install Ruby dependencies!"
    exit 1
fi
