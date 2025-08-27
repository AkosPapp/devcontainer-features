#!/bin/bash

# Simple test to verify nix store info command works

set -e

# Import test library
source dev-container-features-test-lib

echo "Testing core nix functionality..."

# Test that nix binary exists and is executable
check "nix binary exists" test -x "$(which nix)"

# Test that nix store info runs without error
check "nix store info command" nix store info

# Test that nix store info returns expected fields
check "store info contains store dir" bash -c 'nix store info | grep -i "store dir"'

# Test that nix can evaluate expressions
check "nix eval basic math" bash -c 'nix eval --expr "1 + 1" | grep -q "2"'

# Test that nix daemon is running (if applicable)
check "nix ping store" nix store ping || echo "Note: nix store ping may fail in some environments"

echo "Core nix functionality tests completed!"

# Report results
reportResults
