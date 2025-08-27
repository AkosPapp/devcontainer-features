#!/bin/sh

set -eu

if nix store info >/dev/null 2>&1; then
  echo "Nix daemon already running"
else
  sudo nohup setsid nix daemon </dev/null >/dev/null 2>&1
  echo "Nix daemon started"
fi