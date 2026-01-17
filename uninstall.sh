#!/bin/sh

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Rclone Systemd Suite Uninstaller

set -e

usage() {
	cat <<-EOF
	Usage: $(basename "$0") [OPTIONS]

	Options:
		-s, --system    Uninstall system-wide (requires sudo)
		-n, --dry-run   Show commands without executing
		-p, --purge     Also remove configuration files
		-h, --help      Show this help
	EOF
	exit 0
}

DRY_RUN=""
SYSTEM=""
PURGE=""

for arg in "$@"; do
	case "$arg" in
		-s|--system) SYSTEM=1 ;;
		-n|--dry-run) DRY_RUN=1 ;;
		-p|--purge) PURGE=1 ;;
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

UNIT_FILES="rclone-bisync@.{path,service,timer} rclone-rcd-gui.service"
# UNIT_OVERRIDE_DIRS="{rclone-bisync,rclone-rcd-gui}.service.d"

run() {
	if [ "$DRY_RUN" ]; then
		echo "[dry-run] $RUN $*"
	else
		$RUN "$@"
	fi
}

if [ "$DRY_RUN" ]; then
	echo "=== $SCOPE uninstall (dry-run) ==="
	echo "Config dir: $CONF_DIR"
	echo "Systemd dir: $SYSTEMD_DIR"
	echo "Desktop dir: $DESKTOP_DIR"
	echo "systemctl option: ${SYSTEMCTL_OPT:-'(none)'}"
	echo "Purge configs: ${PURGE:-'no'}"
	echo ""
fi

# Stop running instances
for unit in rclone-bisync@*.timer rclone-bisync@*.service rclone-rcd-gui.service; do
	if systemctl $SYSTEMCTL_OPT list-units --full --all 2>/dev/null | grep -q "$unit"; then
		run systemctl $SYSTEMCTL_OPT stop "$unit" 2>/dev/null || true
		run systemctl $SYSTEMCTL_OPT disable "$unit" 2>/dev/null || true
	fi
done

# Remove unit files
for unit in $UNIT_FILES; do
	[ -f "$SYSTEMD_DIR/$unit" ] && run rm -f "$SYSTEMD_DIR/$unit"
done

# Remove unit override files


# Remove .desktop file
[ -f "$DESKTOP_DIR/rclone-rcd-gui.desktop" ] && run rm -f "$DESKTOP_DIR/rclone-rcd-gui.desktop"

# Purge configs if requested
if [ "$PURGE" ]; then
	run rm -rf "$CONF_DIR/rclone-bisync" "$CONF_DIR/rclone-rcd-gui"
fi

run systemctl $SYSTEMCTL_OPT daemon-reload

if [ -z "$DRY_RUN" ]; then
	echo "$SCOPE uninstall done.${PURGE:+ Configs purged.}"
fi
