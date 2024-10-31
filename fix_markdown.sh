#!/bin/bash
# Install Prettier if it's not already installed
if ! command -v prettier &> /dev/null
then
    echo "Prettier not found. Installing..."
    npm install -g prettier
fi

# Run Prettier to format the Markdown file
prettier --write .github/github_token_rotation.md

echo "Markdown file has been formatted using Prettier."