#!/bin/bash

# Docker failure logging utilities for CodeBuild command execution.

reset_docker_failure_logging() {
    unset DOCKER_FAILURE_LOGGED
}

docker_failure_cleanup() {
    local errexit_was_set="$1"
    unset DOCKER_FAILURE_LOGGING_IN_PROGRESS
    reset_docker_failure_logging
    if [ "$errexit_was_set" -eq 1 ]; then
        set -e
    else
        set +e
    fi
}

docker_failure_logs() {
    local exit_code="$1"
    local failed_command="$2"
    local errexit_was_set=0
    local log_lines="${DOCKER_FAILURE_LOG_LINES:-200}"
    local log_command="${DOCKER_FAILURE_LOG_COMMAND:-0}"

    if [ -z "$exit_code" ]; then
        echo "docker_failure_logs: missing exit_code parameter" >&2
        return 1
    fi

    case "$exit_code" in
        *[!0-9]*)
            echo "docker_failure_logs: exit_code must be an integer" >&2
            return 1
            ;;
    esac

    if [ -z "$failed_command" ]; then
        echo "docker_failure_logs: missing failed_command parameter" >&2
        return 1
    fi

    if [ "$exit_code" -eq 0 ]; then
        return
    fi

    if [ -n "${DOCKER_FAILURE_LOGGED:-}" ]; then
        return
    fi

    if [ -n "${DOCKER_FAILURE_LOGGING_IN_PROGRESS:-}" ]; then
        return
    fi

    case $- in
        *e*) errexit_was_set=1 ;;
    esac

    export DOCKER_FAILURE_LOGGED=1
    export DOCKER_FAILURE_LOGGING_IN_PROGRESS=1
    set +e

    redact_common_secrets() {
        local input="$1"
        local -a patterns=("_PASSWORD" "_SECRET" "_TOKEN" "_KEY")
        while IFS='=' read -r name value; do
            [ -z "$name" ] && continue
            [ -z "$value" ] && continue
            local upper_name="${name^^}"
            local matched=0
            for suffix in "${patterns[@]}"; do
                if [[ "$upper_name" == *"$suffix" ]]; then
                    matched=1
                    break
                fi
            done
            [ "$matched" -eq 0 ] && continue
            input="${input//${value}/[REDACTED]}"
        done < <(env)
        echo "$input"
    }

    # redact_common_secrets already scrubs env-derived secrets (e.g., *_PASSWORD, *_SECRET, *_TOKEN, *_KEY).
    if [ "$log_command" -eq 1 ]; then
        if [ -n "${GITHUB_TOKEN:-}" ]; then
            failed_command="${failed_command//${GITHUB_TOKEN}/[REDACTED]}"
        fi
        if [ -n "${DOCKER_PASSWORD:-}" ]; then
            failed_command="${failed_command//${DOCKER_PASSWORD}/[REDACTED]}"
        fi
        if [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
            failed_command="${failed_command//${AWS_SECRET_ACCESS_KEY}/[REDACTED]}"
        fi
        if [ -n "${AWS_SESSION_TOKEN:-}" ]; then
            failed_command="${failed_command//${AWS_SESSION_TOKEN}/[REDACTED]}"
        fi
        if [ -n "${AWS_ACCESS_KEY_ID:-}" ]; then
            failed_command="${failed_command//${AWS_ACCESS_KEY_ID}/[REDACTED]}"
        fi
        failed_command="$(redact_common_secrets "$failed_command")"
        echo "#### Command failed (exit ${exit_code}): ${failed_command}"
    else
        echo "#### Command failed (exit ${exit_code}). Set DOCKER_FAILURE_LOG_COMMAND=1 to print the command."
    fi

    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker CLI is not available. Skipping Docker logs."
        docker_failure_cleanup "$errexit_was_set"
        return
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "Docker daemon is not available. Skipping Docker logs."
        docker_failure_cleanup "$errexit_was_set"
        return
    fi

    echo "#### Docker container status"
    docker ps -a || true

    local -a container_ids
    mapfile -t container_ids < <(docker ps -aq 2>/dev/null || true)
    if [ "${#container_ids[@]}" -eq 0 ]; then
        echo "No Docker containers found."
        docker_failure_cleanup "$errexit_was_set"
        return
    fi

    for container_id in "${container_ids[@]}"; do
        echo "#### Docker logs for ${container_id}"
        docker logs --tail "$log_lines" "$container_id" || true
    done

    docker_failure_cleanup "$errexit_was_set"
}

enable_docker_failure_logging() {
    if [ -n "${DOCKER_FAILURE_LOGGING_ENABLED:-}" ]; then
        return
    fi

    export DOCKER_FAILURE_LOGGING_ENABLED=1
    trap 'docker_failure_logs $? "${BASH_COMMAND:-unknown}"' EXIT
}

if [ -n "${CODEBUILD_BUILD_ID:-}" ]; then
    enable_docker_failure_logging
fi
