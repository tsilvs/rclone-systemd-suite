#!/usr/bin/env bash

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Install:
# Follow README.md

set -euo pipefail

REMOTE="$1"
CONFIG="$HOME/.config/rclone-bisync/config.conf"

# Load user config
# shellcheck source=/dev/null
source "$CONFIG"

LOCAL_PATH="$SYNC_ROOT/$REMOTE"
CACHE_DIR="$SYNC_ROOT/.rclone-bisync/$REMOTE"
CHECK_FILE="RCLONE_TEST"

mkdir -p "$LOCAL_PATH" "$CACHE_DIR"

REAL_PATH=$(readlink -f "$LOCAL_PATH")
LOCK_FILE="/run/user/$UID/rclone-bisync-$(echo "$REAL_PATH" | tr '/' '-')"

export CACHE_DIR LOCAL_PATH REMOTE CHECK_FILE BISYNC_FLAGS

exec flock -w "$LOCK_TIMEOUT" "$LOCK_FILE" bash <<'EOF'
if [ ! -f "$CACHE_DIR/.initialized" ]; then
	echo "bisync-test-$(date +%s)" > "$LOCAL_PATH/$CHECK_FILE"
	rclone copy "$LOCAL_PATH/$CHECK_FILE" "$REMOTE:" --create-empty-src-dirs
	rclone bisync "$LOCAL_PATH" "$REMOTE:" --resync --create-empty-src-dirs
	touch "$CACHE_DIR/.initialized"
	exit 0
fi

rclone bisync "$LOCAL_PATH" "$REMOTE:" \
	--check-access \
	--check-filename "$CHECK_FILE" \
	--track-renames \
	--resilient \
	--recover \
	--conflict-resolve newer \
	--conflict-loser num \
	--create-empty-src-dirs \
	$BISYNC_FLAGS
EOF