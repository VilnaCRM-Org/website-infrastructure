LINK="https://$AWS_REGION.console.aws.amazon.com/s3/buckets/ci-cd-website-$ENVIRONMENT-codepipeline-artifacts-bucket?prefix=ci-cd-website-$ENVIRONMENT-p/$ARTIFACTS_OUTPUT_DIR/&region=$AWS_REGION&bucketType=general"

JSON_STRING=$(jq -n \
    --arg link "$LINK" \
    --arg codebuild_build_id "$CODEBUILD_BUILD_ID" \
    '{link: $bn, codebuild_build_id: $codebuild_build_id}')

export $JSON_STRING
