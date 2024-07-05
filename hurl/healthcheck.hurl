GET https://www.{{website_url}}
HTTP 200

GET https://{{website_url}}
HTTP 200
[Asserts]
certificate "Subject" == "CN = {{website_url}}"
certificate "Issuer" matches "C = US, O = Amazon, CN = Amazon RSA 2048 M[0-9]+"
certificate "Expire-Date" daysAfterNow > 30
certificate "Serial-Number" matches /[\da-f]+/