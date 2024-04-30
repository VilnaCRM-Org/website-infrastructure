export NEXT_PUBLIC_WEBSITE_URL="https://$WEBSITE_URL"
export NEXT_PUBLIC_LOCALHOST="$WEBSITE_URL"
export NEXT_PUBLIC_FALLBACK_LANGUAGE="en"
export NEXT_PUBLIC_GRAPHQL_API_URL="https://$WEBSITE_URL/api/graphql"
export NEXT_PUBLIC_API_URL="https://yourserver.io/api/"
export NEXT_PUBLIC_VILNACRM_GMAIL="info@vilnacrm.com"
export MEMLAB_WEBSITE_URL="https://$WEBSITE_URL"
export WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA=$(git rev-parse HEAD)
export WEBSITE_GIT_REPOSITORY_LAST_COMMIT_NAME=$(git log --format=%B -n 1)
export WEBSITE_GIT_REPOSITORY_LAST_COMMIT_AUTHOR=$(git log -1 --pretty=format:"%an")
