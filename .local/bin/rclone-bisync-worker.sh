#!/usr/bin/env bash

set -euo pipefail

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