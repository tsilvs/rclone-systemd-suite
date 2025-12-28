#!/bin/sh

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Rclone Systemd Suite Installer

set -e

if [ "$1" = "--system" ]; then
	CONF_DIR="/etc"
	SYSTEMD_DIR="/etc/systemd/system"
	SYSTEMCTL_OPT=""
	SCOPE="System"
	RUN="sudo"
	DESKTOP_DIR="/usr/share/applications"
else
	CONF_DIR="$HOME/.config"
	SYSTEMD_DIR="$CONF_DIR/systemd/user"
	SYSTEMCTL_OPT="--user"
	SCOPE="User"
	RUN=""
	DESKTOP_DIR="$HOME/.local/share/applications"
fi

RCLONE_BISYNC_CONFIG="$CONF_DIR/rclone-bisync/conf.env"
RCLONE_RCDGUI_CONFIG="$CONF_DIR/rclone-rcd-gui/conf.env"

$RUN mkdir -p "$CONF_DIR/rclone-bisync" "$CONF_DIR/rclone-rcd-gui" "$SYSTEMD_DIR" "$DESKTOP_DIR"
$RUN cp .config/systemd/user/* "$SYSTEMD_DIR/"
$RUN cp .local/share/applications/* "$DESKTOP_DIR/" 2>/dev/null || true
[ ! -f "$RCLONE_BISYNC_CONFIG" ] && $RUN cp .config/rclone-bisync/.example.conf.env "$RCLONE_BISYNC_CONFIG"
[ ! -f "$RCLONE_RCDGUI_CONFIG" ] && $RUN cp .config/rclone-rcd-gui/.example.conf.env "$RCLONE_RCDGUI_CONFIG"
$RUN systemctl $SYSTEMCTL_OPT daemon-reload

echo "$SCOPE install done. Enable: systemctl $SYSTEMCTL_OPT enable --now rclone-bisync@MyRemote.timer"
