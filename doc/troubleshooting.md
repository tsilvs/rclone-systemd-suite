# Bisync Troubleshooting

## Access test failed (`RCLONE_TEST` missing)

```
ERROR : Access test failed: Path1 count 0, Path2 count 1 - RCLONE_TEST
ERROR : Bisync critical error: check file check failed
```

**Cause:** `CHECK_FILE` (default: `RCLONE_TEST`) deleted from one side. Required sentinel for `--check-access`.

**Fix:** Recreate on local, copy to remote, restart:
```bash
echo "bisync-test-$(date +%s)" > ~/.rclone-bisync/<remote>/RCLONE_TEST
rclone copy ~/.rclone-bisync/<remote>/RCLONE_TEST <remote>:
systemctl --user start rclone-bisync@<remote>.service
```

---

## Too many deletes (>50%)

```
ERROR : Safety abort: too many deletes (>50%, N of M) on Path1
```

**Cause:** Stale cached listings (e.g. from prior failed run) diverged from actual state.

**Fix:** Delete `.initialized` to force resync:
```bash
rm ~/.cache/rclone-bisync/<remote>/.initialized
systemctl --user start rclone-bisync@<remote>.service
```

---

## Missing prior listings (`path1.lst` / `path2.lst`)

```
ERROR : Bisync critical error: cannot find prior Path1 or Path2 listings
```

**Cause:** Prior critical error left only `-new` partial listings; rclone can't find committed ones.

**Fix:** Purge stale rclone-internal bisync state:
```bash
rm ~/.cache/rclone/bisync/home_<user>_.<local-path>..<remote>_.*
systemctl --user start rclone-bisync@<remote>.service
```

> Path slug: replace `/` and `~` with `_` in the local path + remote name. Use `ls ~/.cache/rclone/bisync/` to identify exact filenames.

---

## Symlinks skipped (warnings, not errors)

```
INFO+2: <path>: Can't follow symlink without -L/--copy-links
```

**Cause:** Default behavior — rclone skips symlinks.

**Options:**

| Goal | Config |
|------|--------|
| Silence warnings, keep skipping | `BISYNC_FLAGS=--skip-links` |
| Follow symlinks (copy target content) | `BISYNC_FLAGS=--copy-links` |

> `--copy-links` is **not round-trip safe**: remote stores real files, not symlinks. Avoid if symlinks point outside sync root or to large dirs.

Set in `~/.config/rclone-bisync/<remote>conf.env` for per-remote scope.

---

## Service freezes / hangs indefinitely

```
ERROR : Failed to copy: failed to read destination hash: failed to calculate md5 hash: failed to run "md5sum <path>"
```

**Cause:** `md5sum` stalled on local file (unresponsive encrypted mount or fs). No `TimeoutStartSec` → systemd waits forever.

**Fix:** Kill manually, investigate mount:
```bash
systemctl --user stop rclone-bisync@<remote>.service
# check mount health
ls ~/.rclone-bisync/<remote>/
```

Permanent guard: `TimeoutStartSec=600` in service (already set). Tune to expected max sync duration.

---

## General recovery sequence

1. Check which cache files exist: `ls ~/.cache/rclone/bisync/ | grep <remote>`
2. If only `-new` files: purge them (see "Missing prior listings")
3. If `.initialized` missing: service auto-reruns init — just start it
4. If `.initialized` present but state bad: delete it, restart
5. Nuclear option — full reset:
   ```bash
   rm -f ~/.cache/rclone/bisync/home_<user>_.<local>.*
   rm -f ~/.cache/rclone-bisync/<remote>/.initialized
   systemctl --user start rclone-bisync@<remote>.service
   ```
