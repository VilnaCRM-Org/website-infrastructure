NAME=${CODEBUILD_BUILD_ID%:*}

S3_LINK="https://$AWS_REGION.console.aws.amazon.com/s3/buckets/ci-cd-website-$ENVIRONMENT-codepipeline-artifacts-bucket?prefix=ci-cd-website-$ENVIRONMENT-p/$ARTIFACTS_OUTPUT_DIR/&region=$AWS_REGION&bucketType=general"
CODEBUILD_LINK="https://$AWS_REGION.console.aws.amazon.com/codesuite/codebuild/$ACCOUNT_ID/projects/$NAME/build/$CODEBUILD_BUILD_ID?region=$AWS_REGION"
GITHUB_COMMIT_LINK="$WEBSITE_GIT_REPOSITORY_LINK/commit/$WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA"

JSON_STRING=$(jq -n \
    --arg s3_link "$S3_LINK" \
    --arg gh_link "$GITHUB_COMMIT_LINK" \
    --arg codebuild_link "$CODEBUILD_LINK" \
    '{s3_link: $s3_link, codebuild_link: $codebuild_link, gh_link: $gh_link}')

echo $JSON_STRING >payload.json
