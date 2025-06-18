#!/bin/bash

# Docker Setup Script
# Handles Docker daemon startup and initialization

set -e

echo "#### Starting Docker daemon..."

# Start Docker daemon in background
nohup /usr/local/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375 --storage-driver=overlay2 &

# Wait for Docker to be ready
if timeout 15 sh -c 'until docker info; do echo "Waiting for Docker to start..."; sleep 1; done'; then
    echo "✅ Docker daemon started successfully"
else
    echo "❌ Docker daemon failed to start within 15 seconds"
    exit 1
fi