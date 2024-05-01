NAME=${CODEBUILD_BUILD_ID%:*}
CODEBUILD_LINK="https://$AWS_REGION.console.aws.amazon.com/codesuite/codebuild/$ACCOUNT_ID/projects/$NAME/build/$CODEBUILD_BUILD_ID?region=$AWS_REGION"
GITHUB_COMMIT_LINK="$WEBSITE_GIT_REPOSITORY_LINK/commit/$WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA"

if [ "$LHCI_DESKTOP_RUN" = true ]; then
    LHCI_DESKTOP_RUN_NAME="Lighthouse Desktop Reports"
    directory="/root/website/lhci-reports-desktop"
    LHCI_DESKTOP_RUN_LINKS=""
    for filepath in $(find "$directory" -type f -name "*.html"); do
        filename=$(basename "$filepath")
        temp_link="http://$LHCI_REPORTS_BUCKET.s3-website.$AWS_REGION.amazonaws.com/$CODEBUILD_BUILD_ID/lhci-reports-desktop/$filename;"
        LHCI_DESKTOP_RUN_LINKS="$LHCI_DESKTOP_RUN_LINKS$temp_link"
    done
    aws s3 cp /root/website/lhci-reports-desktop/. s3://$LHCI_REPORTS_BUCKET/$CODEBUILD_BUILD_ID/lhci-reports-desktop --recursive
fi

if [ "$LHCI_MOBILE_RUN" = true ]; then
    LHCI_MOBILE_RUN_NAME="Lighthouse Mobile Reports"
    directory="/root/website/lhci-reports-mobile"
    LHCI_MOBILE_RUN_LINKS=""
    for filepath in $(find "$directory" -type f -name "*.html"); do
        filename=$(basename "$filepath")
        temp_link="http://$LHCI_REPORTS_BUCKET.s3-website.$AWS_REGION.amazonaws.com/$CODEBUILD_BUILD_ID/lhci-reports-mobile/$filename;"
        LHCI_MOBILE_RUN_LINKS="$LHCI_MOBILE_RUN_LINKS$temp_link"
    done

    aws s3 cp /root/website/lhci-reports-mobile/. s3://$LHCI_REPORTS_BUCKET/$CODEBUILD_BUILD_ID/lhci-reports-mobile --recursive
fi

if [ "$PW_E2E_RUN" = true ]; then
    PW_E2E_RUN_NAME="Playwright E2E Report"
    PW_E2E_RUN_LINK="http://$TEST_REPORTS_BUCKET.s3-website.$AWS_REGION.amazonaws.com/$CODEBUILD_BUILD_ID/playwright-e2e-reports"
    aws s3 cp /root/website/playwright-e2e-reports/. s3://$TEST_REPORTS_BUCKET/$CODEBUILD_BUILD_ID/playwright-e2e-reports --recursive
fi

if [ "$PW_VISUAL_RUN" = true ]; then
    PW_VISUAL_RUN_NAME="Playwright Visual Report"
    PW_VISUAL_RUN_LINK="http://$TEST_REPORTS_BUCKET.s3-website.$AWS_REGION.amazonaws.com/$CODEBUILD_BUILD_ID/playwright-visual-reports"
    aws s3 cp /root/website/playwright-visual-reports/. s3://$TEST_REPORTS_BUCKET/$CODEBUILD_BUILD_ID/playwright-visual-reports --recursive
fi

if [ "$MUTATION_RUN" = true ]; then
    MUTATION_RUN_NAME="Mutation Test Report"
    MUTATION_RUN_LINK="http://$TEST_REPORTS_BUCKET.s3-website.$AWS_REGION.amazonaws.com/$CODEBUILD_BUILD_ID/mutation"
    aws s3 cp /root/website/reports/mutation/. s3://$TEST_REPORTS_BUCKET/$CODEBUILD_BUILD_ID/mutation --recursive
fi

if [ "$UNIT_RUN" = true ]; then
    UNIT_RUN_NAME="Unit Test Report"
    UNIT_RUN_LINK="http://$TEST_REPORTS_BUCKET.s3-website.$AWS_REGION.amazonaws.com/$CODEBUILD_BUILD_ID/unit"
    aws s3 cp /root/website/coverage/lcov-report/. s3://$TEST_REPORTS_BUCKET/$CODEBUILD_BUILD_ID/unit --recursive
fi

JSON_STRING=$(jq -n \
    --arg gh_link "$GITHUB_COMMIT_LINK" \
    --arg codebuild_link "$CODEBUILD_LINK" \
    --arg sha "$WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA" \
    --arg author "$WEBSITE_GIT_REPOSITORY_LAST_COMMIT_AUTHOR" \
    --arg name "$WEBSITE_GIT_REPOSITORY_LAST_COMMIT_NAME" \
    --arg lhci_desktop_run_name "$LHCI_DESKTOP_RUN_NAME" \
    --arg lhci_desktop_run_links "$LHCI_DESKTOP_RUN_LINKS" \
    --arg lhci_mobile_run_name "$LHCI_MOBILE_RUN_NAME" \
    --arg lhci_mobile_run_links "$LHCI_MOBILE_RUN_LINKS" \
    --arg pw_e2e_run_name "$PW_E2E_RUN_NAME" \
    --arg pw_e2e_run_link "$PW_E2E_RUN_LINK" \
    --arg pw_visual_run_name "$PW_VISUAL_RUN_NAME" \
    --arg pw_visual_run_link "$PW_VISUAL_RUN_LINK" \
    --arg mutation_run_name "$MUTATION_RUN_NAME" \
    --arg mutation_run_link "$MUTATION_RUN_LINK" \
    --arg unit_run_name "$UNIT_RUN_NAME" \
    --arg unit_run_link "$UNIT_RUN_LINK" \
    '{codebuild_link: $codebuild_link, github: {gh_link: $gh_link, sha: $sha, author: $author, name: $name}, reports: [{name: $lhci_desktop_run_name, link: $lhci_desktop_run_links}, {name: $lhci_mobile_run_name, link: $lhci_mobile_run_links}, {name: $pw_e2e_run_name, link: $pw_e2e_run_link}, {name: $pw_visual_run_name, link: $pw_visual_run_link}, {name: $mutation_run_name, link: $mutation_run_link}, {name: $unit_run_name, link: $unit_run_link}] }')

echo $JSON_STRING >payload.json
