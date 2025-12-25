#!/bin/bash
set -euo pipefail

REMOTE="$1"
LOCAL_BASE="${RCLONE_BISYNC_BASE:-$HOME/Sync}"
LOCAL_PATH="$LOCAL_BASE/$REMOTE"
CACHE_DIR="$LOCAL_BASE/.rclone-bisync/$REMOTE"
CHECK_FILE="RCLONE_TEST"

mkdir -p "$LOCAL_PATH" "$CACHE_DIR"

# First run: create check file + resync
if [ ! -f "$CACHE_DIR/.initialized" ]; then
	echo "bisync-test-$(date +%s)" > "$LOCAL_PATH/$CHECK_FILE"
	rclone copy "$LOCAL_PATH/$CHECK_FILE" "$REMOTE:" --create-empty-src-dirs
	rclone bisync "$LOCAL_PATH" "$REMOTE:" --resync --create-empty-src-dirs
	touch "$CACHE_DIR/.initialized"
	exit 0
fi

# Normal run
rclone bisync "$LOCAL_PATH" "$REMOTE:" \
	--check-access \
	--check-filename "$CHECK_FILE" \
	--track-renames \
	--resilient \
	--recover \
	--conflict-resolve newer \
	--conflict-loser num \
	--create-empty-src-dirs \
	--verbose