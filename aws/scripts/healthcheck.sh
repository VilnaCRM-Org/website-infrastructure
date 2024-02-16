#!/bin/bash

# Check if the website URL is provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <website_url>"
    exit 1
fi

# Set the URL of the website from the command-line argument
website_url="$1"

# Set the file path where you want to save the retrieved file
output_file="output.html"

# Function to check if the website is alive with HTTP 200 status
check_website() {
    response=$(curl -s -o /dev/null -w "%{http_code}" "https://$website_url")

    if [[ "$response" -eq 200 ]]; then
        echo "$website_url returned 200."
        return 0
    else
        echo "$website_url returned $response."
        return 1
    fi

}

# Function to verify SSL/TLS certificate validity
verify_certificate() {
    cert=$(openssl s_client -connect $website_url:443 -servername $website_url </dev/null 2>/dev/null | openssl x509 -noout -dates)

    end_date=$(echo $cert | sed -n '/notAfter/s/^.*=//p')

    end_date_sec=$(date -d "$end_date" +%s)

    current_sec=$(date +%s)

    days_until_expire=$((($end_date_sec - $current_sec) / 86400))

    if [ $days_until_expire -le 30 ]; then
        echo "The certificate for $website_url is close to expiring ($days_until_expire days left)."
        return 1
    else
        echo "The certificate for $website_url is valid."
        return 0
    fi
}

retrieve_file() {
    if curl --silent --fail "$1" -o "$2"; then
        echo "File retrieved successfully"
    else
        echo "Failed to retrieve file"
    fi
}

# Final check
if check_website "$website_url"; then
    if verify_certificate "$website_url"; then
        retrieve_file "$website_url" "$output_file"
    else
        echo "Exiting script due to SSL/TLS certificate issues"
        exit 1
    fi
else
    echo "Exiting script due to non-200 HTTP status"
    exit 1
fi
