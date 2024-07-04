#!/bin/bash

if [ "$IS_PULL_REQUEST" -eq 1 ]; then
    echo $GITHUB_TOKEN >token.txt
    gh auth login --with-token <token.txt
    gh pr comment $PR_NUMBER -R $GITHUB_REPOSITORY --body "Latest Version is ready: http://$PROJECT_NAME-$BRANCH_NAME.s3-website.$AWS_DEFAULT_REGION.amazonaws.com"
fi
