#!/bin/bash

# Docker-in-Docker Configuration Script
# Applies modifications for true DinD environment

set -e

echo "#### Applying true DinD modifications for CodeBuild environment"

# Add DIND variable to Makefile
if ! grep -q "DIND" Makefile; then
    sed -i '/^CI[[:space:]]*?= 0$/a DIND                        ?= 0' Makefile
fi

# Modify docker-compose.yml for true DinD networking
# Add container name for dev service
sed -i '/^  dev:$/a \    container_name: website-dev' docker-compose.yml

# Add networks section to dev service (before volumes section)
sed -i '/^    volumes:$/i \    networks:\n      - website-network' docker-compose.yml

# Modify docker-compose.test.yml for true DinD networking
# Define services that need container names and networks
services="prod playwright apollo mockoon k6"

for service in $services; do
    # Add container name if not already present
    if ! grep -q "container_name: website-$service" docker-compose.test.yml; then
        sed -i "/^  $service:$/a \\    container_name: website-$service" docker-compose.test.yml
    fi
    
    # Add networks section if not already present for this service
    if ! sed -n "/^  $service:/,/^  [a-zA-Z]/p" docker-compose.test.yml | grep -q "networks:"; then
        # Find the appropriate place to insert networks (before volumes, ports, environment, healthcheck, or depends_on)
        sed -i "/^  $service:/,/^  [a-zA-Z]/ {
            /^    \(volumes\|ports\|environment\|healthcheck\|depends_on\):/i \\    networks:\\n      - website-network
            t
            /^  [a-zA-Z]/i \\    networks:\\n      - website-network
        }" docker-compose.test.yml
    fi
done

echo "✅ DinD configuration completed successfully" 