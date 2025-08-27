#!/bin/bash

# This test file will be executed against a container with the
# nix-devcontainer feature installed.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' function is a part of the devcontainer-features-test-lib.
echo "Testing nix installation..."

# Test that nix command is available
check "nix command available" which nix

# Test that nix store is working
check "nix store info" nix store info

# Test that nix can evaluate simple expressions
check "nix eval simple expression" bash -c 'nix eval --expr "1 + 1" | grep -q "2"'

# Test that nix can install a simple package
check "nix shell hello package" bash -c 'nix shell nixpkgs#hello --command hello | grep -q "Hello, world!"'

# Test that volumes are mounted correctly
check "nix store volume mounted" test -d /nix/store

# Test that nix config directory exists
check "nix config directory exists" test -d /etc/nix

# Report results
reportResults
