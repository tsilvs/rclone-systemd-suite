#!/usr/bin/env bash

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Install:
# Follow README.md

set -euo pipefail

REMOTE="$1"

# Normalize remote path (ensure it ends with :)
REMOTE="${REMOTE%:}:"

# Use environment variables provided by systemd
# SYNC_ROOT, CACHE_DIR, LOCK_FILE, LOCK_TIMEOUT, BISYNC_FLAGS are set in unit file
LOCAL_PATH="$SYNC_ROOT/$REMOTE"
CHECK_FILE="${CHECK_FILE:-RCLONE_TEST}"

mkdir -p "$LOCAL_PATH" "$CACHE_DIR"

export CACHE_DIR LOCAL_PATH REMOTE CHECK_FILE BISYNC_FLAGS

exec flock -w "$LOCK_TIMEOUT" "$LOCK_FILE" "$(dirname "$0")/rclone-bisync-worker.sh"

