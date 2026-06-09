# Monitor UI — Implementation Notes

## Monitoring Concerns

Two distinct data sources:

| Widget | Command | Params |
|--------|---------|--------|
| Remote disk usage | `ssh <host> 'du -h -d1 ~/rclone/<remote> \| sort -rh'` | `SSH_HOST`, `REMOTE_RCLONE_PATH` |
| Service status | `systemctl --user status rclone-bisync@<instance>` | `INSTANCE` |

### Parametrization

```sh
INSTANCE=itldc-hd-crypt           # matches systemd instance name (%i)
SSH_HOST=itldc.hd.krakua           # explicit or derived from instance name
REMOTE_RCLONE_PATH=~/rclone/Crypt  # corresponds to service LOCAL_PATH
WATCH_INTERVAL=1                   # seconds
```

---

## Planned Scripts

```
scripts/
  monitor.sh          # tmux session: both watch loops in split panes (interactive)
  widget-status.sh    # single-line stdout: for status bars (waybar/polybar/i3blocks)
  notify-on-fail.sh   # notify-send alert: hooked via systemd OnFailure=
```

### `monitor.sh`
Full interactive view. Spawns tmux session with two panes:
- pane 0: `watch -c -d -n $WATCH_INTERVAL ssh $SSH_HOST "du -h -d1 $REMOTE_RCLONE_PATH | sort -rh"`
- pane 1: `watch -c -n $WATCH_INTERVAL systemctl --user status rclone-bisync@$INSTANCE`

### `widget-status.sh`
Stdout one-liner: last sync time + status icon. Shared interface for all bars:
- exit 0 + stdout = status text consumed by waybar `custom/`, polybar `custom/script`, i3blocks

### `notify-on-fail.sh`
`notify-send` alert. Integrate with existing systemd unit:
```ini
[Unit]
OnFailure=rclone-bisync-notify@%i.service
```

---

## Display Approaches

### 1. Floating Terminal Window (most compatible)

Launch a terminal with a WM float rule on `WM_CLASS` or window title.

| Terminal | Flag |
|----------|------|
| alacritty | `--class rclone-monitor` |
| kitty | `--title rclone-monitor` |
| foot | `--app-id rclone-monitor` |
| xterm | `-name rclone-monitor` |

WM rule example (sway / i3):
```
for_window [app_id="rclone-monitor"] floating enable, move position 0 0
```

### 2. Status Bar Widgets

All bars consume the same `widget-status.sh` script (stdout + exit code interface):

| Bar | Config key | Ecosystem |
|-----|------------|-----------|
| waybar | `custom/` module | Wayland (sway, hyprland, niri) |
| i3blocks | block `command=` | i3 / sway |
| polybar | `custom/script` | X11 (i3, openbox, bspwm) |
| lemonbar | stdin pipe | Any X11 WM |

### 3. Desktop Widgets (wallpaper layer)

| Tool | Compatibility | Notes |
|------|---------------|-------|
| **eww** | X11 + Wayland | GTK, declarative `.yuck`, WM-agnostic, feeds from shell scripts |
| conky | X11 (partial Wayland) | Widely available, scriptable |
| ags | Wayland only | JS config, modern |

**eww** preferred: X11 + Wayland, WM-agnostic, driven directly by shell scripts.

### 4. Notification Daemon (alerts only)

`notify-send` works on any DE with a notification daemon (dunst, mako, swaync, KDE, GNOME).
Use for failure alerts via `OnFailure=`, not live status.

---

## Autostart

### XDG Autostart (DE-agnostic)

Place in `~/.config/autostart/`. Respected by GNOME, KDE, XFCE, and any XDG-compliant DE.

Template: `.config/autostart/rclone-bisync-monitor.tpl.desktop`
```ini
[Desktop Entry]
Type=Application
Name=Rclone Bisync Monitor
Exec=alacritty --class rclone-monitor -e tmux new-session -s rclone-monitor 'scripts/monitor.sh INSTANCE SSH_HOST'
X-GNOME-Autostart-enabled=true
```

User fills `INSTANCE` and `SSH_HOST` during `install.sh` (same pattern as existing `.tpl.desktop` files).

### Bare WM

Source `monitor.sh` from WM startup config directly (e.g., `exec`, `exec-once`, `spawn`).

---

## Repo Integration Plan

```
scripts/
  monitor.sh
  widget-status.sh
  notify-on-fail.sh
.config/
  autostart/
    rclone-bisync-monitor.tpl.desktop
  eww/                                  # optional
    rclone.yuck
```

- `install.sh` — instantiate `.tpl.desktop` → `~/.config/autostart/`
- `uninstall.sh` — remove generated `.desktop`
