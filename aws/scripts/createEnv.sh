website_url=$1

echo NEXT_PUBLIC_WEBSITE_URL = "https://$website_url" >.env
echo NEXT_PUBLIC_LOCALHOST = "$website_url" >>.env
echo NEXT_PUBLIC_FALLBACK_LANGUAGE = "en" >>.env
echo NEXT_PUBLIC_GRAPHQL_API_URL = "https://$website_url/api/graphql" >>.env
echo NEXT_PUBLIC_API_URL = "https://yourserver.io/api/" >>.env
echo NEXT_PUBLIC_VILNACRM_GMAIL = "info@vilnacrm.com" >>.env
echo MEMLAB_WEBSITE_URL = "https://$website_url" >>.env
