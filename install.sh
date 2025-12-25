#!/bin/sh

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Install:
# Follow README.md

set -e
mkdir -p "$HOME/.local/bin" "$HOME/.config/rclone-bisync" "$HOME/.config/systemd/user"
cp rclone-bisync.sh "$HOME/.local/bin/"
cp rclone-bisync-worker.sh "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/rclone-bisync.sh" "$HOME/.local/bin/rclone-bisync-worker.sh"
cp rclone-bisync@.service rclone-bisync@.timer rclone-bisync@.path rclone-bisync.sh rclone-bisync-worker.sh "$HOME/.config/systemd/user/"
chmod +x "$HOME/.config/systemd/user/rclone-bisync.sh" "$HOME/.config/systemd/user/rclone-bisync-worker.sh"
cp .config/rclone-bisync/.example.conf "$HOME/.config/rclone-bisync/config.conf"
systemctl --user daemon-reload