#!/usr/bin/env bash

set -eux
set -o pipefail

# Check that Nix is installed
if ! command -v nix &> /dev/null
then
  echo "Nix is not installed on the target host. Make sure that the image you're using comes with Nix pre-installed."
  exit
fi

echo Installing cachix...
nix-env -iA cachix -f https://cachix.org/api/v1/install

# TODO: Remove once switched to release
# Set up binary cache for development versions of cachix
cachix --host https://stagix.org use cachix-sandydoo --mode root-nixconf

export $(cat /etc/cachix-agent.token)

echo "Launching the Cachix Deploy agent..."
# cachix deploy agent ${var.agent_name} --bootstrap
nix run github:sandydoo/cachix/feature/455 \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes \
  -- \
  --host https://stagix.org deploy agent $1 --bootstrap
