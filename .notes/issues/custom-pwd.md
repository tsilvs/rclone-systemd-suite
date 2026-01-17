## What is the problem?

Cannot login to Web GUI when using `--rc-user` and `--rc-pass` flags. Browser login form rejects all credentials, even though rclone logs show authentication is configured.

## System Information

- **rclone version:** `v1.69.2` (run `rclone version`)
- **OS:** Fedora Atomic 41 (Bazzite)
- **Architecture:** x86_64
- **Browser:** Firefox/Chrome

```console
$> rclone --version
rclone v1.71.0
- os/version: fedora 42 (64 bit)
- os/kernel: 6.16.4-114.bazzite.fc42.x86_64 (x86_64)
- os/type: linux
- os/arch: amd64
- go/version: go1.25rc2 X:nodwarf5
- go/linking: dynamic
- go/tags: none
```

## Command
```bash
rclone rcd --rc-web-gui --rc-addr=127.0.0.1:5572 --rc-user=admin --rc-pass=testpass
```

## Logs
```
Jan 17 21:18:05 rclone[428367]: INFO: Using --user admin --pass XXXX as authenticated user
Jan 17 21:18:05 rclone[428367]: NOTICE: Serving remote control on http://127.0.0.1:5572/
Jan 17 21:18:05 rclone[428367]: Web GUI is not automatically opening browser. Navigate to http://admin:testpass@127.0.0.1:5572/?login_token=...
```

Process shows correct flags:
```
/usr/bin/rclone rcd --rc-web-gui --rc-addr=127.0.0.1:5572 --rc-user=admin --rc-pass=testpass
```

## Behavior

1. Web GUI loads correctly at `http://127.0.0.1:5572`
2. Login form appears requesting credentials
3. Entering `admin/testpass` results in login loop
4. No authentication errors in logs - just returns to login form
5. Token URL from logs also fails to authenticate

## Tested

- ✅ Direct command: `rclone rcd --rc-web-gui --rc-user=test --rc-pass=test`
- ✅ Multiple passwords (alphanumeric, mixed case)
- ✅ Browser cache cleared, incognito mode
- ✅ Service restart, process verification
- ❌ All credentials rejected

## Workaround

`--rc-no-auth` works (localhost only):
```bash
rclone rcd --rc-web-gui --rc-addr=127.0.0.1:5572 --rc-no-auth
```

## Related Issues

Similar reports from 2019-2020:
- #4708 (2020) - Same "Unauthorized request" with `--rc-user/--rc-pass`
- rclone/rclone-webui-react#37 (2019) - Login failure with manual auth

## Question

Is `--rc-user`/`--rc-pass` authentication still supported for Web GUI login? Documentation suggests it should work, but multiple users report failures spanning 2019-2026.

Alternative: Should users switch to `--rc-htpasswd` for Web GUI authentication?

---

Issue form:

```md
<!--

We understand you are having a problem with rclone; we want to help you with that!

**STOP and READ**
**YOUR POST WILL BE REMOVED IF IT IS LOW QUALITY**:
Please show the effort you've put into solving the problem and please be specific.
People are volunteering their time to help! Low effort posts are not likely to get good answers!

If you think you might have found a bug, try to replicate it with the latest beta (or stable).
The update instructions are available at https://rclone.org/commands/rclone_selfupdate/

If you can still replicate it or just got a question then please use the rclone forum:

    https://forum.rclone.org/

for a quick response instead of filing an issue on this repo.

If nothing else helps, then please fill in the info below which helps us help you.

**DO NOT REDACT** any information except passwords/keys/personal info.

You should use 3 backticks to begin and end your paste to make it readable.

Make sure to include a log obtained with '-vv'.

You can also use '-vv --log-file bug.log' and a service such as https://pastebin.com or https://gist.github.com/

Thank you

The Rclone Developers

-->

#### The associated forum post URL from `https://forum.rclone.org`



#### What is the problem you are having with rclone?



#### What is your rclone version (output from `rclone version`)



#### Which OS you are using and how many bits (e.g. Windows 7, 64 bit)



#### Which cloud storage system are you using? (e.g. Google Drive)



#### The command you were trying to run (e.g. `rclone copy /tmp remote:tmp`)



#### A log from the command with the `-vv` flag (e.g. output from `rclone -vv copy /tmp remote:tmp`)



<!--- Please keep the note below for others who read your bug report. -->

#### How to use GitHub

* Please use the 👍 [reaction](https://blog.github.com/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/) to show that you are affected by the same issue.
* Please don't comment if you have no relevant information to add. It's just extra noise for everyone subscribed to this issue.
* Subscribe to receive notifications on status change and new comments.
```
