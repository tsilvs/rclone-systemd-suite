# Rclone Systemd Suite

Offline-capable bidirectional sync with systemd automation.

Services to efficiently manage RClone jobs on multiple remotes, i.e.:

+ [x] Near-instant Bisync / "cached mount"
+ [ ] Launch GUI service

## Use case

This setup is designed with the following usage scenario in mind:

+ Basic assumption is that `MyRemote` is configured properly in current user's `rclone.conf`. i.e.:
	+ If it needs to be encrypted, it's an RClone remote `type = crypt`;
	+ If it's a specific path on a remote `MyRemoteRoot`, it is specified in `MyRemote` of `type` `crypt` or `alias` as `remote = MyRemoteRoot:MyPath`;
+ Core purpose of `MyRemote` is to be an access point for multiple devices to share the most up-to-date file tree state:
	+ Permanent deletions are not of any concern;
	+ Reserve copies with N historical versions of a file should be handled by `rclone-backup@MyBackup.service`;
+ If the `rclone-sync@MyRemote.service` is enabled, it acts as an init, health-check and sync;
+ Sync strategy essentially reproduces `mount` with offline capabilities, i.e. if `MyRemote` is inaccessible, or `rclone-sync@MyRemote.service` is deactivated, files are still available offline;

## Installation

```bash
# Copy files
sudo cp rclone-bisync.sh /etc/systemd/system/
sudo cp rclone-bisync@.service /etc/systemd/system/
sudo cp rclone-bisync@.timer /etc/systemd/system/

# Make script executable
sudo chmod +x /etc/systemd/system/rclone-bisync.sh

# Reload systemd
sudo systemctl daemon-reload
```

## Usage

```bash
# Enable timer for remote
sudo systemctl enable --now rclone-bisync@MyRemote.timer

# Manual sync
sudo systemctl start rclone-bisync@MyRemote.service

# Check status
systemctl status rclone-bisync@MyRemote.timer
journalctl -u rclone-bisync@MyRemote.service -f
```

## Target Directory Structure

```tree
MySyncBase
├── .rclone-bisync/          # Cache
│   └── MyRemote/
│       └── .initialized
└── MyRemote/                # Synced files
```

## Configuration

Default sync base: `~/Sync`

Override via environment in service file:
```ini
Environment="RCLONE_BISYNC_BASE=/custom/path"
```

## Timer Settings

Default: 2min after boot, then every 15min

Adjust in `rclone-bisync@.timer`:
```ini
OnBootSec=2min
OnUnitActiveSec=15min
```

## Android Setup (Round Sync)

1. Install [Round Sync](https://github.com/newhinton/Round-Sync)
2. Add remote: `MyRemote:`
3. Set local path: `/storage/emulated/0/Sync/MyRemote/`
4. Set interval: 20+ min (stagger from Linux timer)
5. Create `RCLONE_TEST` file in local folder first time
6. Enable bidirectional sync

## Requirements

- Rclone configured with remotes in `~/.config/rclone/rclone.conf`
- Works with `crypt`, `alias`, any rclone remote type
- Network connectivity (falls back to offline when unavailable)

## Features

- Auto-initialization with `--resync`
- Deletion tracking
- Rename detection
- Conflict resolution (keeps newer, renames loser)
- Auto-recovery from crashes
- Check access verification
- Empty directory creation



