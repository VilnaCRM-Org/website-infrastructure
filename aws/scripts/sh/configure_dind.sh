#!/bin/bash

# Docker-in-Docker Configuration Script
# Applies modifications for true DinD environment

set -e

echo "#### Applying true DinD modifications for CodeBuild environment"

# Add DIND variable to Makefile
if ! grep -q "DIND" Makefile; then
    sed -i '/^CI[[:space:]]*?= 0$/a DIND                        ?= 0' Makefile
fi

# Modify Dockerfile to use latest package versions
echo "#### Modifying Dockerfile to use latest package versions..."
sed -i 's/python3=3.12.10-r1/python3/g' Dockerfile
sed -i 's/make=4.4.1-r2/make/g' Dockerfile
sed -i 's/g++=14.2.0-r4/g++/g' Dockerfile
sed -i 's/curl=8.12.1-r1/curl/g' Dockerfile

# Modify docker-compose.yml for true DinD networking
# Add container name for dev service
sed -i '/^  dev:$/a \    container_name: website-dev' docker-compose.yml

# Add networks section to dev service (before volumes section)
sed -i '/^    volumes:$/i \    networks:\n      - website-network' docker-compose.yml

# Add networks section at the end of the file
cat >> docker-compose.yml << 'EOF'

networks:
  website-network:
    external: true
    name: website-network
EOF

# Modify docker-compose.test.yml for true DinD networking
# Add container names and networks for test services
sed -i '/^  prod:$/a \    container_name: website-prod' docker-compose.test.yml
sed -i '/^  playwright:$/a \    container_name: website-playwright' docker-compose.test.yml
sed -i '/^  apollo:$/a \    container_name: website-apollo' docker-compose.test.yml
sed -i '/^  mockoon:$/a \    container_name: website-mockoon' docker-compose.test.yml
sed -i '/^  k6:$/a \    container_name: website-k6' docker-compose.test.yml
sed -i '/^    healthcheck:$/i \    networks:\n      - website-network' docker-compose.test.yml

# Add networks section at the end of test compose file
cat >> docker-compose.test.yml << 'EOF'

networks:
  website-network:
    external: true
    name: website-network
EOF

echo "✅ DinD configuration completed successfully" 