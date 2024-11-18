#!/bin/bash
echo #### Install Software
n install "${NODEJS_VERSION:?Node.js version is not set}"
n "${NODEJS_VERSION:?Node.js version is not set}"
git clone -b "$WEBSITE_GIT_REPOSITORY_BRANCH" "$WEBSITE_GIT_REPOSITORY_LINK.git" /codebuild-user/website
cd /codebuild-user/website/ || {
    echo "Error: Failed to change directory to website folder" >&2
    exit 1
}
echo #### Install pnpm
npm install -g pnpm || {
    echo "Error: Failed to install pnpm" >&2
    exit 1
}
echo #### Install dependencies
make install || {
    echo "Error: Failed to install dependencies" >&2
    exit 1
}
