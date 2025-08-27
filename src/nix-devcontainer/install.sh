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
        echo "build-users-group = nixbld"
        echo "sandbox = true"
        echo "substituters = https://cache.nixos.org/"
        echo "trusted-substituters = https://cache.nixos.org/"
    } | sudo tee /etc/nix/nix.conf > /dev/null
fi

cp src/nix-daemon.sh /

NUM_USERS=${1:-32}   # Number of build users (32 is the default for modern Nix)
BASE_NAME="nixbld"
START_UID=30000
START_GID=30000
SHARED_GROUP="nixbld"

echo "Creating shared group '$SHARED_GROUP' if it does not exist..."
if ! getent group "$SHARED_GROUP" > /dev/null; then
    groupadd "$SHARED_GROUP"
fi

echo "Creating $NUM_USERS Nix build users..."
for i in $(seq 1 "$NUM_USERS"); do
    USERNAME="${BASE_NAME}${i}"

    if id "$USERNAME" &>/dev/null; then
        echo "User $USERNAME already exists, skipping..."
        # Ensure the user is in the shared group
        usermod -aG "$SHARED_GROUP" "$USERNAME" || true
        continue
    fi

    # Create a dedicated group for each user
    groupadd -g $((START_GID + i)) "$USERNAME" || true

    # Create the user with no login and empty home, primary group is the dedicated group
    useradd \
        -u $((START_UID + i)) \
        -g "$USERNAME" \
        -G "$SHARED_GROUP" \
        -d /var/empty \
        -s /usr/sbin/nologin \
        -c "Nix build user $USERNAME" \
        "$USERNAME"

    echo "Created user $USERNAME with UID $((START_UID + i)) and added to group '$SHARED_GROUP'"
done

echo "All Nix build users are ready and belong to the shared group '$SHARED_GROUP'."