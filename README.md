# Rclone Systemd Suite

A few configs for efficient and convenient RClone management.

## Features

+ Rclone RCD Web GUI to IDE integration
+ Bidirectional sync with systemd automation.

## Quick Start

```bash
./install.sh
# Enable Sync on Timer
systemctl --user enable --now rclone-bisync@MyRemote.timer
# Enable Sync on Path Watch
systemctl --user enable --now rclone-bisync@MyRemote.path
```

## Configuration

Configuration files follow systemd's standard precedence:
- System-wide: `/etc/rclone-bisync/` and `/etc/rclone-rcd-gui/`
- User-specific: `~/.config/rclone-bisync/` and `~/.config/rclone-rcd-gui/`

Built-in defaults are provided by the systemd units and can be overridden by creating configuration files in the directories above.

## Custom Timer

Create override files for custom intervals:

```bash
mkdir -p ~/.config/systemd/user/rclone-bisync@MyRemote.timer.d
cat > ~/.config/systemd/user/rclone-bisync@MyRemote.timer.d/override.conf <<EOF
[Timer]
OnBootSec=10min
OnUnitActiveSec=30min
EOF
systemctl --user daemon-reload
```

## Custom Path Watcher

Create override files for custom paths:

```bash
mkdir -p ~/.config/systemd/user/rclone-bisync@MyRemote.path.d
cat > ~/.config/systemd/user/rclone-bisync@MyRemote.path.d/override.conf <<EOF
[Path]
# Note: Paths are relative to SYNC_ROOT (default: ~/Sync)
# Set SYNC_ROOT in ~/.config/rclone-bisync/@MyRemote.config if needed
PathModified=%i/
PathChanged=%i/
EOF
systemctl --user daemon-reload
```
