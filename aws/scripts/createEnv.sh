website_url=$1

export NEXT_PUBLIC_WEBSITE_URL="https://$website_url" >.env
export NEXT_PUBLIC_LOCALHOST="$website_url" >>.env
export NEXT_PUBLIC_FALLBACK_LANGUAGE="en" >>.env
export NEXT_PUBLIC_GRAPHQL_API_URL="https://$website_url/api/graphql" >>.env
export NEXT_PUBLIC_API_URL="https://yourserver.io/api/" >>.env
export NEXT_PUBLIC_VILNACRM_GMAIL="info@vilnacrm.com" >>.env
export MEMLAB_WEBSITE_URL="https://$website_url" >>.env
