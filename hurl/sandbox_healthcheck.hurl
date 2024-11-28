GET {{bucket_url}}
HTTP 200
[Asserts]
header "Content-Type" exists
body matches "<ListBucketResult"