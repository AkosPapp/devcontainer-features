#!/bin/sh

# This test file will be executed against a container with the
# nix-devcontainer feature installed.

set -e

. ./dev-container-features-test-lib.sh


# Feature-specific tests
echo "Testing nix installation..."

check "nix exe exists" ls -lh /bin/nix

# Test that nix command is available
check "nix command available" command -v nix

# Test that nix store is working
check "nix store info" nix store info

# Test that nix can evaluate simple expressions
check "nix eval simple expression" sh -c 'nix eval --expr "1 + 1" | grep -q "2"'

# Test that nix can install a simple package
check "nix shell hello package" sh -c 'nix shell nixpkgs#hello --command hello | grep -q "Hello, world!"'

# Report results
reportResults
