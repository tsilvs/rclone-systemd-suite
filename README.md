# Rclone Systemd Suite

Bidirectional sync with systemd automation.

## Quick Start

```bash
./install.sh
systemctl --user enable --now rclone-bisync@MyRemote.timer
```

## Per-Remote Timer Customization

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

## Event-Driven Sync

Enable path monitoring for immediate sync:

```bash
systemctl --user enable --now rclone-bisync@MyRemote.path
```

Watches `~/Sync/MyRemote/` (uses `%h/Sync/%i/` from systemd path unit).
Override path by creating systemd override with custom `PathModified`/`PathChanged`.
