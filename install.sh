#!/bin/sh

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Installation process:

set -e

# + for userspace

# TODO: Same as below
# FIXME: Decide on a parameter set!!!
# FIXME: Decide on installation procedure!!!
# FIXME: Decide on source dir file structure!!!

mkdir -p "$HOME/.local/bin" "$HOME/.config/rclone-bisync" "$HOME/.config/rclone-rcd-gui" "$HOME/.config/systemd/user"

# Copy binary files
cp .local/bin/* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/rclone-bisync.sh" "$HOME/.local/bin/rclone-bisync-worker.sh"

# Copy configuration templates
cp .config/rclone-bisync/.example.conf "$HOME/.config/rclone-bisync/config.conf"
cp .config/rclone-rcd-gui/.example.conf "$HOME/.config/rclone-rcd-gui/config.conf"

# Copy systemd unit files
cp .config/systemd/user/* "$HOME/.config/systemd/user/"

