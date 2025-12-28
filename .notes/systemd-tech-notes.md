# Specifiers

## Host & OS

| Meaning          | Specifier | Use | Details                                                                                                                                                                    |
|------------------|-----------|-----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Architecture     | `%a`      | -   | Short string identifying system architecture (e.g., `x86`, `x86-64`, `arm64`). Matches values accepted by `ConditionArchitecture=`.                                        |
| Kernel release   | `%v`      | -   | Output of `uname -r`.                                                                                                                                                      |
| Machine ID       | `%m`      | -   | System machine ID as string. See [`machine-id(5)`](https://man7.org/linux/man-pages/man5/machine-id.5.html).                                                               |
| OS image version | `%A`      | -   | From `IMAGE_VERSION=` in `/etc/os-release`; empty if unset. See [`os-release(5)`](https://man7.org/linux/man-pages/man5/os-release.5.html).                                |
| OS build ID      | `%B`      | -   | From `BUILD_ID=` in `/etc/os-release`; empty if unset.                                                                                                                     |
| OS image ID      | `%M`      | -   | From `IMAGE_ID=` in `/etc/os-release`; empty if unset.                                                                                                                     |
| OS ID            | `%o`      | -   | From `ID=` in `/etc/os-release`.                                                                                                                                           |
| OS version ID    | `%w`      | -   | From `VERSION_ID=` in `/etc/os-release`; empty if unset.                                                                                                                   |
| OS variant ID    | `%W`      | -   | From `VARIANT_ID=` in `/etc/os-release`; empty if unset.                                                                                                                   |
| Host name        | `%H`      | ?   | System hostname when unit config loaded.                                                                                                                                   |
| Short host name  | `%l`      | ?   | Hostname truncated at first dot (no domain).                                                                                                                               |
| Pretty host name | `%q`      | ?   | From `PRETTY_HOSTNAME=` in `/etc/machine-info`; falls back to short hostname if unset. See [`machine-info(5)`](https://man7.org/linux/man-pages/man5/machine-info.5.html). |
| Boot ID          | `%b`      | -   | System boot ID as string. See [`random(4)`](https://man7.org/linux/man-pages/man4/random.4.html).                                                                          |

## User

| Meaning    | Specifier | Use | Details                                                                                          |
|------------|-----------|-----|--------------------------------------------------------------------------------------------------|
| User shell | `%s`      | -   | Shell of service manager user.                                                                   |
| User group | `%g`      | -   | Group of service manager user. `root` for system manager.                                        |
| User GID   | `%G`      | -   | Numeric GID of service manager user. `0` for system manager.                                     |
| User name  | `%u`      | +   | Name of service manager user. `root` for system manager. Not affected by `User=` in `[Service]`. |
| User UID   | `%U`      | ?   | Numeric UID of service manager user. `0` for system manager. Not affected by `User=`.            |

## Unit

| Context  | Specifier | Use | Meaning                          | Details                                                                                                       |
|----------|-----------|-----|----------------------------------|---------------------------------------------------------------------------------------------------------------|
| File     | `%f`      | ?   | Unescaped filename               | Unescaped instance name with `/` prepended, or unescaped prefix with `/`. Uses systemd path unescaping rules. |
| unit     | `%n`      | +   | Full unit name                   | Full name including instance and type (e.g., `foo@bar.service`).                                              |
| Unit     | `%N`      | +   | Unit name without type           | Same as `%n` but without `.service`, `.timer`, etc.                                                           |
| Prefix   | `%p`      | +   | Prefix name                      | For instantiated units: part before first `@`. Otherwise: `%N`.                                               |
| prefix   | `%P`      | +   | Unescaped prefix name            | Same as `%p`, unescaped.                                                                                      |
| prefix   | `%j`      | +   | Final prefix component           | String after last `-` in prefix; equals `%p` if no `-` exists.                                                |
| prefix   | `%J`      | +   | Unescaped final prefix component | Same as `%j`, unescaped.                                                                                      |
| Instance | `%i`      | +   | Instance name                    | String between first `@` and unit type suffix. Empty for non-instantiated units.                              |
| instance | `%I`      | +   | Unescaped instance name          | Same as `%i`, unescaped.                                                                                      |
| Runtime  | `%t`      | +   | Runtime directory root           | `/run` (system) or `$XDG_RUNTIME_DIR` (user).                                                                 |
| fragment | `%y`      | ?   | Unit fragment path               | Path to main unit file. For symlinks, uses real path. Fails if no fragment exists.                            |
| fragment | `%Y`      | ?   | Unit fragment directory          | Directory of `%y`.                                                                                            |

## File system paths

| Context | Specifier | Use | Meaning                              | Details                                                                                                                              |
|---------|-----------|-----|--------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| Dir     | `%d`      | -   | Credentials directory                | From `$CREDENTIALS_DIRECTORY` if set. See [systemd.exec(5) §Credentials](https://man7.org/linux/man-pages/man5/systemd.exec.5.html). |
| Dir     | `%S`      | +   | State directory root                 | `/var/lib` (system) or `$XDG_STATE_HOME` (user).                                                                                     |
| Dir     | `%C`      | +   | Cache directory root                 | `/var/cache` (system) or `$XDG_CACHE_HOME` (user).                                                                                   |
| Dir     | `%D`      | +   | Shared data directory                | `/usr/share` (system) or `$XDG_DATA_HOME` (user).                                                                                    |
| Dir     | `%E`      | +   | Configuration directory root         | `/etc` (system) or `$XDG_CONFIG_HOME` (user).                                                                                        |
| Dir     | `%L`      | +   | Log directory root                   | `/var/log` (system) or `$XDG_STATE_HOME/log` (user).                                                                                 |
| Dir     | `%h`      | +   | User home directory                  | Home of service manager user. `/root` for system manager. Not affected by `User=` in `[Service]`.                                    |
| Dir     | `%T`      | +   | Temporary files directory            | `/tmp` or value of `$TMPDIR`, `$TEMP`, or `$TMP` (no trailing slash).                                                                |
| Dir     | `%V`      | +   | Persistent temporary files directory | `/var/tmp` or value of `$TMPDIR`, `$TEMP`, or `$TMP` (no trailing slash).                                                            |

## Special characters

| Context | Specifier | Use | Meaning              | Details                             |
|---------|-----------|-----|----------------------|-------------------------------------|
| sign    | `%%`      | +   | Literal percent sign | Use `%%` to represent a single `%`. |

# Unit types

| Suffix       | Type |
|--------------|------|
| `.service`   |      |
| `.socket`    |      |
| `.device`    |      |
| `.mount`     |      |
| `.automount` |      |
| `.swap`      |      |
| `.target`    |      |
| `.path`      |      |
| `.timer`     |      |
| `.slice`     |      |
| `.scope`     |      |

# Unit Search Path¶

## System

```
/etc/systemd/system/*
/etc/systemd/system.control/*
/etc/systemd/system.attached/*
```

## User

```
/etc/systemd/user/*
~/.config/systemd/user/*
~/.config/systemd/user.control/*
```

<details>
	<summary>Extra</summary>

```
$XDG_CONFIG_DIRS/systemd/user/*
$XDG_DATA_DIRS/systemd/user/*
$XDG_DATA_HOME/systemd/user/*
$XDG_RUNTIME_DIR/systemd/generator.early/*
$XDG_RUNTIME_DIR/systemd/generator.late/*
$XDG_RUNTIME_DIR/systemd/generator/*
$XDG_RUNTIME_DIR/systemd/transient/*
$XDG_RUNTIME_DIR/systemd/user.control/*
$XDG_RUNTIME_DIR/systemd/user/*
```

</details>


