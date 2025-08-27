#!/bin/bash

# Test specifically for nix store info functionality

set -e

# Import test library
source dev-container-features-test-lib

echo "Testing nix store info command..."

# Test that nix store info command works and produces expected output
check "nix store info runs successfully" nix store info

# Test that nix store info shows store path
check "nix store info shows store path" bash -c 'nix store info | grep -q "store dir:"'

# Test that nix store info shows state version
check "nix store info shows state version" bash -c 'nix store info | grep -q "state version:"'

# Report results
reportResults
