#!/bin/sh

set -eu

cd $(dirname $0)

echo $PWD

ARCH=$(arch)

for src in $(find src/result/${ARCH}-linux -type f); do
    dst="/${src#src/result/${ARCH}-linux/}"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
done


for src in $(find src/result/global -type f); do
    dst="/${src#src/result/global/}"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
done

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
    } > /etc/nix/nix.conf
fi

cp src/nix-daemon.sh /

NUM_USERS=${1:-32}   # Number of build users (32 is the default for modern Nix)
BASE_NAME="nixbld"
START_UID=30000
SHARED_GROUP="nixbld"

# Detect if we're on Alpine/BusyBox (which uses addgroup/adduser) or other systems (groupadd/useradd)
# Use BusyBox commands if groupmod doesn't exist (indicating minimal environment)
if command -v groupmod >/dev/null 2>&1; then
    USE_BUSYBOX_COMMANDS=0
else
    USE_BUSYBOX_COMMANDS=1
fi

# Find the correct nologin path
if [ -x /sbin/nologin ]; then
    NOLOGIN_PATH="/sbin/nologin"
elif [ -x /usr/sbin/nologin ]; then
    NOLOGIN_PATH="/usr/sbin/nologin"
elif [ -x /bin/false ]; then
    NOLOGIN_PATH="/bin/false"
else
    NOLOGIN_PATH="/dev/null"
fi

echo "Creating shared group '$SHARED_GROUP' if it does not exist..."
if ! getent group "$SHARED_GROUP" >/dev/null 2>&1; then
    if [ "$USE_BUSYBOX_COMMANDS" = "1" ]; then
        addgroup "$SHARED_GROUP"
    else
        groupadd "$SHARED_GROUP"
    fi
fi

echo "Creating $NUM_USERS Nix build users..."
i=1
while [ $i -le "$NUM_USERS" ]; do
    USERNAME="${BASE_NAME}${i}"

    if id "$USERNAME" >/dev/null 2>&1; then
        echo "User $USERNAME already exists, skipping..."
        # Ensure the user is in the shared group
        if [ "$USE_BUSYBOX_COMMANDS" = "1" ]; then
            addgroup "$USERNAME" "$SHARED_GROUP" 2>/dev/null || true
        else
            usermod -aG "$SHARED_GROUP" "$USERNAME" || true
        fi
        i=$((i + 1))
        continue
    fi

    # Create the user with no login and empty home, using the shared group as primary group
    if [ "$USE_BUSYBOX_COMMANDS" = "1" ]; then
        adduser -u $((START_UID + i)) -G "$SHARED_GROUP" -h /var/empty -s "$NOLOGIN_PATH" -g "Nix build user $USERNAME" -D "$USERNAME"
    else
        sudo useradd -g nixbld -G nixbld -M -N -u $((30000 + i)) nixbld$i || true

        # useradd \
            # -u $((START_UID + i)) \
            # -g "$SHARED_GROUP" \
            # -G "$SHARED_GROUP" \
            # -d /var/empty \
            # -s "$NOLOGIN_PATH" \
            # -c "Nix build user $USERNAME" \
            # "$USERNAME"
    fi

    echo "Created user $USERNAME with UID $((START_UID + i)) and added to group '$SHARED_GROUP'"
    i=$((i + 1))
done

echo "All Nix build users are ready and belong to the shared group '$SHARED_GROUP'."