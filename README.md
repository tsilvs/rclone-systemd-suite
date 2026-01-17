# Rclone Systemd Suite

Systemd units for RClone bidirectional sync + RCD Web GUI.

## Install

```bash
# User (default)
./install.sh

# System-wide (root, e.g. for config backups)
sudo ./install.sh --system
```

## Run

### GUI

```sh
# There is a .desktop file for that, but you can control it from terminal
# User (default)

source ~/.config/rclone-rcd-gui/conf.env;
systemctl --user \
	is-active --quiet rclone-rcd-gui.service \
|| systemctl --user \
	start rclone-rcd-gui.service

# or `enable --now` if you want it to run on startup

# And then open http://${RC_ADDR}:${RC_PORT}, default is http://localhost:5572
```
<!-- `# System-wide (root, e.g. for config backups)` -->

### Sync

```bash
# User (default)
systemctl --user enable --now rclone-bisync@MyRemote.timer

# System-wide (root, e.g. for config backups)
sudo systemctl enable --now rclone-bisync@MyRemote.timer
```

#### Triggers

Timer (periodic) + path watcher (on-change) conflict by design - use one:

```bash
# Timer-based (default: 15min intervals)
systemctl --user enable --now rclone-bisync@MyRemote.timer

# Path-based (on local file changes)
systemctl --user enable --now rclone-bisync@MyRemote.path
```

## Config

### `rclone-bisync`

Precedence:

1. Built-in defaults in unit files
2. Overrides: `~/.config/systemd/user/rclone-bisync.service.d/YourOverride.conf`
3. System: `/etc/rclone-bisync/.config`, `/etc/rclone-bisync/MyRemote.config`
4. User: `~/.config/rclone-bisync/.config`, `~/.config/rclone-bisync/MyRemote.config`

Variables:

+ `SYNC_ROOT`
+ `BISYNC_FLAGS`
+ `CHECK_FILE`
+ `LOCAL_PATH`
+ `CACHE_DIR`

### `rclone-rcd-gui`

Precedence:

1. Built-in defaults in unit files
2. Overrides: `~/.config/systemd/user/rclone-rcd-gui.service.d/MyOverride.conf`
3. Config - System: `/etc/rclone-rcd-gui/.config`, `/etc/rclone-rcd-gui/MyRemote.config`
4. Config - User: `~/.config/rclone-rcd-gui/.config`, `~/.config/rclone-rcd-gui/MyRemote.config`

## Custom Timer

```bash
mkdir -p ~/.config/systemd/user/rclone-bisync@MyRemote.timer.d
cat > ~/.config/systemd/user/rclone-bisync@MyRemote.timer.d/override.conf <<'EOF'
[Timer]
OnBootSec=10min
OnUnitActiveSec=30min
EOF
systemctl --user daemon-reload
```

## Custom Path Watcher

```bash
mkdir -p ~/.config/systemd/user/rclone-bisync@MyRemote.path.d
cat > ~/.config/systemd/user/rclone-bisync@MyRemote.path.d/override.conf <<'EOF'
[Path]
PathModified=/custom/path/
PathChanged=/custom/path/
EOF
systemctl --user daemon-reload
```

## System-Wide Usage

For system config backups or shared sync (e.g. `/etc` backup to cloud):

```bash
sudo ./install.sh --system
# Configure remote-specific settings
sudo editor /etc/rclone-bisync/MyRemote.config
sudo systemctl enable --now rclone-bisync@MyRemote.timer
```

Note: System units run as root. Configure `LOCAL_PATH` appropriately.

