+ [x] Check if [`.dekstop`](../.local/share/applications/rclone-rcd-gui.desktop) is ok
+ [x] Test [`install`](../install.sh)
+ [x] Test [`uninstall`](../uninstall.sh)
+ [ ] Test run on `GDriveTest` remote:

> [!IMPORTANT]
> + `w/`, `w/o` - with/out
> + `OR` - overrides
> + `CF` - config files
> + `N(TestCases) = 8`

# `rclone-rcd-gui`

| Scope  | w/o CF    |          | w/ CF     |          |
|--------|-----------|----------|-----------|----------|
| User   | w/o OR: ✅ | w/ OR: ✅ | w/o OR: ❔ | w/ OR: ❔ |
| System | w/o OR: ❔ | w/ OR: ❔ | w/o OR: ❔ | w/ OR: ❔ |

# `rclone-bisync`

| Scope  | w/o CF    |          | w/ CF     |          |
|--------|-----------|----------|-----------|----------|
| User   | w/o OR: ❔ | w/ OR: ❔ | w/o OR: ❔ | w/ OR: ❔ |
| System | w/o OR: ❔ | w/ OR: ❔ | w/o OR: ❔ | w/ OR: ❔ |

# TODO

## Immediate

+ [ ] Edit `~/.config/rclone-bisync/conf.env`:
	+ [ ] Fix comments syntax for SystemD parsing
	+ [ ] Set `SYNC_ROOT`

