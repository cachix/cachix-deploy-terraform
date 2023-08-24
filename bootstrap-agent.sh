#!/usr/bin/env bash

set -eux
set -o pipefail

host=$1
binary_cache=$2
agent_name=$3
agent_profile=${4:-""}

# Check that Nix is installed
if ! command -v nix &> /dev/null
then
  echo "Nix is not installed on the target host. Make sure that the image you're using comes with Nix pre-installed."
  exit
fi

echo Installing cachix...
nix-env --install --attr cachix --file https://cachix.org/api/v1/install

# TODO: Remove once switched to release
# Set up binary cache for development versions of cachix
cachix --host $host use $binary_cache --mode root-nixconf

export $(cat /etc/cachix-agent.token)

echo "Launching the Cachix Deploy agent..."
cachix --host $host deploy agent $agent_name $agent_profile --bootstrap
