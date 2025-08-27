#!/bin/bash

# The 'test/_global' folder is a special test folder that is not tied to a single feature.
#
# This test file is executed against a running container constructed
# from the value of 'nix_devcontainer_integration' in the tests/_global/scenarios.json file.
#
# The value of a scenarios element is any properties available in the 'devcontainer.json'.
# Scenarios are useful for testing specific options in a feature, or to test a combination of features.
# 
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test --global-scenarios-only .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

echo -e "Testing Nix DevContainer integration:\n"

# Test that nix is available and functional
check "nix command available" which nix
check "nix store info" nix store info
check "nix eval works" bash -c 'nix eval --expr "42" | grep -q "42"'

# Test basic nix functionality
check "nix can run hello" bash -c 'nix run nixpkgs#hello --command hello | grep -q "Hello, world!"'

echo -e "\nNix DevContainer integration test completed successfully!"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
