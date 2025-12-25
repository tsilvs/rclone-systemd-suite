#!/usr/bin/env bash

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Install:
# Follow README.md

set -euo pipefail

REMOTE="$1"
CONFIG="$HOME/.config/rclone-bisync/config.conf"

# Check config file exists
if [ ! -f "$CONFIG" ]; then
    echo "Error: Config file not found at $CONFIG" >&2
    exit 1
fi

# Load user config
# shellcheck source=/dev/null
source "$CONFIG"

# Normalize remote path (ensure it ends with :)
REMOTE="${REMOTE%:}:"

LOCAL_PATH="$SYNC_ROOT/$REMOTE"
CACHE_DIR="$SYNC_ROOT/.rclone-bisync/$REMOTE"
CHECK_FILE="RCLONE_TEST"

mkdir -p "$LOCAL_PATH" "$CACHE_DIR"

REAL_PATH=$(readlink -f "$LOCAL_PATH" || echo "$LOCAL_PATH")
LOCK_FILE="/run/user/$UID/rclone-bisync-$(echo "$REAL_PATH" | tr '/' '-')"

export CACHE_DIR LOCAL_PATH REMOTE CHECK_FILE BISYNC_FLAGS

exec flock -w "$LOCK_TIMEOUT" "$LOCK_FILE" "$(dirname "$0")/rclone-bisync-worker.sh"