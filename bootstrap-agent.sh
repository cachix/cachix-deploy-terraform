#!/usr/bin/env bash

set -eux
set -o pipefail

host=$1
agent_name=$3
agent_profile=${4:-""}
cachix_package=$2

# Check that Nix is installed
if ! command -v nix &> /dev/null
then
  echo "Nix is not installed on the target host. Make sure that the image you're using comes with Nix pre-installed."
  exit
fi

echo Installing cachix...

nix-env --install --attr nixpkgs.jq

binary_cache_name=cachix-sandydoo
binary_cache_public_key=$(
  curl \
    -X "GET" \
    "https://$host/api/v1/cache/$binary_cache_name" \
    -H "accept: application/json;charset=utf-8"
)

{
  nix-env \
    --install \
    --prebuilt-only \
    --extra-substituters $binary_cache_name \
    --extra-trusted_public_keys $binary_cache_public_key \
    --attr cachix \
    --file $cachix_package
} || {
  nix-env \
    --install \
    --prebuilt-only \
    --extra-substituters $binary_cache_name \
    --extra-trusted_public_keys $binary_cache_public_key \
    --file $cachix_package
}

export $(cat /etc/cachix-agent.token)

echo "Launching the Cachix Deploy agent..."
cachix --host $host deploy agent $agent_name $agent_profile --bootstrap

