#!/bin/sh

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Install:
# Follow README.md

set -e
mkdir -p "$HOME/.local/bin" "$HOME/.config/rclone-bisync" "$HOME/.config/systemd/user"

cp .local/ "$HOME/.local/"
chmod +x "$HOME/.local/bin/rclone-bisync.sh" "$HOME/.local/bin/rclone-bisync-worker.sh"

cp .config/ "$HOME/.config/"
cp "$HOME/.config/rclone-bisync/.example.conf" "$HOME/.config/rclone-bisync/config.conf"

systemctl --user daemon-reload
