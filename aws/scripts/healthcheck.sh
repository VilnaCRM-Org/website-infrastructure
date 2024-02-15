#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <website_url>"
    exit 1
fi

website_url="$1"

output_file="output.html"

check_website() {
    if curl --head --silent --fail "$1" >/dev/null; then
        echo "Website is alive"
        return 0
    else
        echo "Website is not reachable"
        return 1
    fi
}

retrieve_file() {
    if curl --silent --fail "$1" -o "$2"; then
        echo "File retrieved successfully"
    else
        echo "Failed to retrieve file"
    fi
}

if check_website "$website_url"; then
    retrieve_file "$website_url" "$output_file"
else
    echo "Exiting script"
    exit 1
fi
