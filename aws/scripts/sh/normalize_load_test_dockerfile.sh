#!/bin/bash

set -e

dockerfile_candidates=(
    "$CODEBUILD_SRC_DIR"/website/tests/load/Dockerfile
    "$CODEBUILD_SRC_DIR"/website/src/test/load/Dockerfile
)

for candidate in "${dockerfile_candidates[@]}"; do
    if [ -f "$candidate" ]; then
        LOAD_TEST_DOCKERFILE="$candidate"
        break
    fi
done

if [ -z "${LOAD_TEST_DOCKERFILE:-}" ]; then
    echo "Failed to locate website load-test Dockerfile." >&2
    printf 'Checked paths:\n- %s\n' "${dockerfile_candidates[@]}" >&2
    exit 1
fi

echo "Normalizing website load-test Dockerfile base images: $LOAD_TEST_DOCKERFILE"

sed -i \
    -E \
    -e 's|^([Ff][Rr][Oo][Mm][[:space:]]+)(--platform=[^[:space:]]+[[:space:]]+)?(docker\.io/library/)?golang:([^[:space:]]+)([[:space:]]+[Aa][Ss][[:space:]]+[^[:space:]]+)?$|\1\2public.ecr.aws/docker/library/golang:\4\5|' \
    -e 's|^([Ff][Rr][Oo][Mm][[:space:]]+)(--platform=[^[:space:]]+[[:space:]]+)?(docker\.io/library/)?golang([[:space:]]+[Aa][Ss][[:space:]]+[^[:space:]]+)?$|\1\2public.ecr.aws/docker/library/golang:latest\4|' \
    -e 's|^([Ff][Rr][Oo][Mm][[:space:]]+)(--platform=[^[:space:]]+[[:space:]]+)?(docker\.io/library/)?alpine:([^[:space:]]+)([[:space:]]+[Aa][Ss][[:space:]]+[^[:space:]]+)?$|\1\2public.ecr.aws/docker/library/alpine:\4\5|' \
    -e 's|^([Ff][Rr][Oo][Mm][[:space:]]+)(--platform=[^[:space:]]+[[:space:]]+)?(docker\.io/library/)?alpine([[:space:]]+[Aa][Ss][[:space:]]+[^[:space:]]+)?$|\1\2public.ecr.aws/docker/library/alpine:latest\4|' \
    "$LOAD_TEST_DOCKERFILE"

if offending_refs=$(grep -Ei '^[Ff][Rr][Oo][Mm][[:space:]]+(--platform=[^[:space:]]+[[:space:]]+)?((docker\.io/library/)?(golang|alpine))([:[:space:]]|$)' "$LOAD_TEST_DOCKERFILE"); then
    echo "Load-test Dockerfile still references Docker Hub base images after normalization:" >&2
    echo "$offending_refs" >&2
    exit 1
fi

echo "Using load-test Dockerfile base images:"
grep -Ei '^[Ff][Rr][Oo][Mm][[:space:]]+' "$LOAD_TEST_DOCKERFILE"
