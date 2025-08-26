#!/usr/bin/env bash

set -euo pipefail

cd $(dirname $0)

echo $PWD

ARCH=$(arch)

cp -r src/result/${ARCH}-linux/* /

mkdir -p /etc/nix /nix/store /nix/var/nix

if [ ! -f /etc/nix/nix.conf ]; then
    {
        echo "cores = 0"
        echo "experimental-features = nix-command flakes"
        echo "max-jobs = auto"
        echo "trusted-users = *"
    } | sudo tee /etc/nix/nix.conf > /dev/null
fi