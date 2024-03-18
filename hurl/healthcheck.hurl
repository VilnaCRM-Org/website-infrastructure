GET https://www.{{website_url}}
HTTP 200

GET https://{{website_url}}
HTTP 200
[Asserts]
certificate "Subject" == "CN = {{website_url}}"
certificate "Issuer" == "C = US, O = Amazon, CN = Amazon RSA 2048 M03"
certificate "Expire-Date" daysAfterNow > 30
certificate "Serial-Number" matches /[\da-f]+/