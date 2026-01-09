#!/bin/bash

# Docker failure logging utilities for CodeBuild command execution.

docker_failure_logs() {
    local exit_code="$1"
    local failed_command="$2"

    if [ -n "${DOCKER_FAILURE_LOGGING_IN_PROGRESS:-}" ]; then
        return
    fi

    export DOCKER_FAILURE_LOGGING_IN_PROGRESS=1
    set +e

    docker_failure_cleanup() {
        unset DOCKER_FAILURE_LOGGING_IN_PROGRESS
        set -e
    }

    echo "#### Command failed (exit ${exit_code}): ${failed_command}"

    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker CLI is not available. Skipping Docker logs."
        docker_failure_cleanup
        return
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "Docker daemon is not available. Skipping Docker logs."
        docker_failure_cleanup
        return
    fi

    echo "#### Docker container status"
    docker ps -a || true

    local container_ids
    container_ids="$(docker ps -aq 2>/dev/null || true)"
    if [ -z "$container_ids" ]; then
        echo "No Docker containers found."
        docker_failure_cleanup
        return
    fi

    for container_id in $container_ids; do
        echo "#### Docker logs for ${container_id}"
        docker logs --tail 200 "$container_id" || true
    done

    docker_failure_cleanup
}

enable_docker_failure_logging() {
    if [ -n "${DOCKER_FAILURE_LOGGING_ENABLED:-}" ]; then
        return
    fi

    export DOCKER_FAILURE_LOGGING_ENABLED=1
    set -E
    trap 'docker_failure_logs $? "${BASH_COMMAND:-unknown}"' ERR
}
