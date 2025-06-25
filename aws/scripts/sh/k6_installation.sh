#!/bin/bash

# Install k6 using the official binary release
echo "Installing k6 binary..."
apk add --no-cache curl tar || {
    echo "Failed to install curl and tar" >&2
    exit 1
}

# Download and install k6 binary
K6_VERSION="v0.49.0"
echo "Downloading k6 ${K6_VERSION}..."
curl -L "https://github.com/grafana/k6/releases/download/${K6_VERSION}/k6-${K6_VERSION}-linux-amd64.tar.gz" -o k6.tar.gz || {
    echo "Failed to download k6" >&2
    exit 1
}

echo "Extracting k6..."
tar -xzf k6.tar.gz || {
    echo "Failed to extract k6" >&2
    exit 1
}

echo "Installing k6..."
mv "k6-${K6_VERSION}-linux-amd64/k6" /usr/local/bin/ || {
    echo "Failed to move k6 binary" >&2
    exit 1
}

# Clean up
rm -rf k6.tar.gz "k6-${K6_VERSION}-linux-amd64"

# Verify installation
k6 version || {
    echo "Failed to verify k6 installation" >&2
    exit 1
}

# Configure load test settings
echo "Configuring load test settings..."
cat "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json.dist > "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json

# Check if we're in DinD mode and configure accordingly
# Force DinD mode detection for docker:dind image
if docker info 2>/dev/null | grep -q "docker:dind" || [ "${DIND:-0}" = "1" ]; then
    echo "Configuring for DinD mode - using container networking"
    # For DinD mode, use container names and HTTP protocol
    sed -i 's/"host": "prod"/"host": "website-prod"/' "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
    echo "✅ DinD mode: Keeping HTTP protocol and using container name 'website-prod'"
else
    echo "Configuring for production deployment"
    # For production deployment, use external URLs
    sed -i "s/http/https/" "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
    sed -i "s/localhost/$WEBSITE_URL/" "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
    sed -i "s/3000/443/" "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
    sed -i "s/Continuous-Deployment-Header-Name/aws-cf-cd-$CLOUDFRONT_HEADER/" "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
    sed -i "s/continuous-deployment-header-value/$CLOUDFRONT_HEADER/" "$CODEBUILD_SRC_DIR"/website/src/test/load/config.json
fi

echo "k6 installation completed successfully!"
