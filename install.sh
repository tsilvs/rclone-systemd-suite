#!/usr/bin/env bash

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Rclone Systemd Suite Installer

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
	cat <<-EOF
	Usage: $(basename "$0") [OPTIONS]

	Options:
		-s, --system              Install system-wide (requires sudo)
		-n, --dry-run             Show commands without executing
		-N, --dry-run-show-files  Like --dry-run + show generated file contents
		--overwrite-env           Overwrite existing conf.env files
		-h, --help                Show this help
	EOF
	exit 0
}

DRY_RUN=""
DRY_RUN_SHOW_FILES=""
SYSTEM=""
OVERWRITE_ENV=""

for arg in "$@"; do
	case "$arg" in
		-s|--system) SYSTEM=1 ;;
		-n|--dry-run) DRY_RUN=1 ;;
		-N|--dry-run-show-files) DRY_RUN=1; DRY_RUN_SHOW_FILES=1 ;;
		-W|--overwrite-env) OVERWRITE_ENV=1 ;;
		-h|--help) usage ;;
	esac
done

if [ "$SYSTEM" ]; then
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

run() {
	if [ "$DRY_RUN" ]; then
		echo "[dry-run] $RUN $*"
	else
		$RUN "$@"
	fi
}

if [ "$DRY_RUN" ]; then
	echo "=== $SCOPE install (dry-run) ==="
	echo "Script dir: $SCRIPT_DIR"
	echo "Config dir: $CONF_DIR"
	echo "Systemd dir: $SYSTEMD_DIR"
	echo "Desktop dir: $DESKTOP_DIR"
	echo "systemctl option: ${SYSTEMCTL_OPT:-'(none)'}"
	echo "Overwrite env: ${OVERWRITE_ENV:-no}"
	echo ""
fi

run mkdir -p "$CONF_DIR"/rclone-{bisync,rcd-gui} "$SYSTEMD_DIR" "$DESKTOP_DIR"
run cp "$SCRIPT_DIR/.config/systemd/user"/* "$SYSTEMD_DIR/"

# Generate .desktop from template
if [ -f "$SCRIPT_DIR/.local/share/applications/rclone-rcd-gui.tpl.desktop" ]; then
	sed -e "s|@CONFIG_PATH@|$RCLONE_RCDGUI_CONFIG|g" \
			-e "s| @SYSTEMCTL_OPT@|${SYSTEMCTL_OPT:+ $SYSTEMCTL_OPT}|g" \
			"$SCRIPT_DIR/.local/share/applications/rclone-rcd-gui.tpl.desktop" > /tmp/rclone-rcd-gui.desktop
	if [ "$DRY_RUN" ]; then
		if [ "$DRY_RUN_SHOW_FILES" ]; then
			echo "[dry-run] Generated .desktop content:"
			cat /tmp/rclone-rcd-gui.desktop
			echo ""
		fi
		echo "[dry-run] $RUN install -m 644 /tmp/rclone-rcd-gui.desktop $DESKTOP_DIR/rclone-rcd-gui.desktop"
	else
		$RUN install -m 644 /tmp/rclone-rcd-gui.desktop "$DESKTOP_DIR/rclone-rcd-gui.desktop"
	fi
	rm -f /tmp/rclone-rcd-gui.desktop
fi

# Install config files
if [ "$OVERWRITE_ENV" ] || [ ! -f "$RCLONE_BISYNC_CONFIG" ]; then
	run cp "$SCRIPT_DIR/.config/rclone-bisync/.example.conf.env" "$RCLONE_BISYNC_CONFIG"
fi

if [ "$OVERWRITE_ENV" ] || [ ! -f "$RCLONE_RCDGUI_CONFIG" ]; then
	run cp "$SCRIPT_DIR/.config/rclone-rcd-gui/.example.conf.env" "$RCLONE_RCDGUI_CONFIG"
fi

run systemctl $SYSTEMCTL_OPT daemon-reload

if [ -z "$DRY_RUN" ]; then
	echo "$SCOPE install done. Enable: systemctl $SYSTEMCTL_OPT enable --now rclone-bisync@MyRemote.timer"
fi
