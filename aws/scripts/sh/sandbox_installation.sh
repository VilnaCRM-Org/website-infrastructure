#!/bin/bash
echo #### Install Software
n install 21.7.1
git clone -b "$BRANCH_NAME" "$WEBSITE_GIT_REPOSITORY_LINK.git" /codebuild-user/website
cd /codebuild-user/website/ || exit 1
echo #### Install pnpm
npm install -g pnpm
echo #### Install dependencies
make install
