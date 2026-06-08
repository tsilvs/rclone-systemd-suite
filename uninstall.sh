#!/usr/bin/env bash

# Copyright (c) 2025 Vsevolod Tsiliurik
# SPDX-License-Identifier: AGPL-3.0-or-later

# Rclone Systemd Suite Uninstaller

set -e

usage() {
	cat <<-EOF
		Usage: $(basename "$0") [OPTIONS]

		Options:
			-h, --help      Show this help
			-n, --dry-run   Show commands without executing
			-s, --system    Uninstall system-wide (requires sudo)
			-p, --purge     Also remove configuration files
	EOF
	exit 0
}

DRY_RUN=""
SYSTEM=""
PURGE=""

for arg in "$@"; do
	case "$arg" in
	-h | --help) usage ;;
	-n | --dry-run) DRY_RUN=1 ;;
	-s | --system) SYSTEM=1 ;;
	-p | --purge) PURGE=1 ;;
	esac
done

# -- Manifest (edit here when adding/removing units) ---------------------
UNIT_GLOBS=(
	rclone-bisync@*.timer
	rclone-bisync@*.service
	rclone-rcd-gui.service
)
UNIT_FILES=(
	rclone-bisync@.path
	rclone-bisync@.service
	rclone-bisync@.timer
	rclone-rcd-gui.service
)
OVERRIDE_DIRS=(
	rclone-bisync@.service.d
	rclone-rcd-gui.service.d
)
DESKTOP_FILES=(
	rclone-rcd-gui.desktop
)
CONF_DIRS=(
	rclone-bisync
	rclone-rcd-gui
)
# ------------------------------------------------------------------------

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

run() {
	if [ "$DRY_RUN" ]; then
		printf '[dry-run]%s' "${RUN:+ $RUN}"
		printf ' %q' "$@"
		echo
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
	echo "Purge configs: ${PURGE:-no}"
	echo ""
fi

# Stop and disable all running instances
for unit in "${UNIT_GLOBS[@]}"; do
	if systemctl $SYSTEMCTL_OPT list-units --full --all 2>/dev/null | grep -qF "$unit"; then
		run systemctl $SYSTEMCTL_OPT stop "$unit" 2>/dev/null || true
		run systemctl $SYSTEMCTL_OPT disable "$unit" 2>/dev/null || true
	fi
done

# Remove unit files
for unit in "${UNIT_FILES[@]}"; do
	run rm -f "$SYSTEMD_DIR/$unit"
done

# Remove unit override directories
for override_dir in "${OVERRIDE_DIRS[@]}"; do
	run rm -rf "$SYSTEMD_DIR/$override_dir"
done

# Remove .desktop files
for desktop in "${DESKTOP_FILES[@]}"; do
	run rm -f "$DESKTOP_DIR/$desktop"
done

# Purge configs if requested
if [ "$PURGE" ]; then
	for conf_dir in "${CONF_DIRS[@]}"; do
		run rm -rf "$CONF_DIR/$conf_dir"
	done
fi

run systemctl $SYSTEMCTL_OPT daemon-reload

if [ -z "$DRY_RUN" ]; then
	echo "$SCOPE uninstall done.${PURGE:+ Configs purged.}"
fi
