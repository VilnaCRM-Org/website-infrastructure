#!/bin/bash
echo #### Install Software
n install "${NODEJS_VERSION:?Node.js version is not set}" || { echo "Error: Failed to install Node.js ${NODEJS_VERSION}" >&2; exit 1; }

# Validate required environment variables
: "${WEBSITE_GIT_REPOSITORY_LINK:?Repository link is not set}"
: "${BRANCH_NAME:?Branch name is not set}"
git clone -b "$BRANCH_NAME" "$WEBSITE_GIT_REPOSITORY_LINK.git" /codebuild-user/website || {
    echo "Error: Failed to clone repository" >&2
    exit 1
}

cd /codebuild-user/website/ || exit 1

echo #### Install pnpm
npm install -g pnpm || { echo "Error: Failed to install pnpm" >&2; exit 1; }