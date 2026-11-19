# Validate what laptop.sh writes to /etc/hosts and ~/.ssh

Open findings:

- `find_01JhxaaHcHsp4MRviPjJHTY5` (low): `bin/hostctl` writes a
  remote hosts list to `/etc/hosts` as root with no checks.
- `find_017Zhy1qDifSHkXc17yVN8M2` (low): `laptop.sh` creates
  `~/.ssh` with the umask mode, not 0700.

The two findings share no cause. They share this plan because each
fix is small and each one is in `laptop.sh` or a script it runs.

## Problem

Proven paths at `ed65118`:

- `bin/hostctl:37` runs this pipeline:

  ```sh
  curl -s https://winhelp2002.mvps.org/hosts.txt |
    tr -d '\r' | sudo tee /etc/hosts
  ```

  The operator of that site, or a person who controls its content,
  sets each line of `/etc/hosts`. A downloaded line for a name that
  the script also writes comes first, so it wins over the line from
  `bin/hostctl:40`. In blocking mode, only the download supplies
  `localhost`. `laptop.sh:426` runs `bin/hostctl` on each run.
- `laptop.sh:42` runs `mkdir -p "$HOME/.ssh"` and sets no mode. On a
  machine where `laptop.sh` creates `~/.ssh` first, the directory
  gets mode 0755 under the default umask. Another local account can
  then read `known_hosts` and `config.private*`.

Sibling path that no finding names:

- `curl -s` has no `-f`. An HTTP error page goes into `/etc/hosts`.
  If the download fails, `tee` has already emptied the file. Then
  `set -euo pipefail` (`bin/hostctl:10`) stops the script before
  lines 40 and 44, and `/etc/hosts` has no `localhost` line.

## Decision

On 2026-11-19 the user decided that the strict filter below is the
only check on what `bin/hostctl` writes. The list has no digest pin.

After the filter, the upstream site can only block a name. It cannot
send a name to an address that it chooses. The user sees a blocked
site at once, and `hostctl --unblock` undoes it. A digest would
freeze a list that nobody reads line by line, and each upstream
update would need a change to this repo.

The `AGENTS.md` rule for a pinned version and a SHA-256 applies to a
tool that `laptop.sh` installs. The hosts list is data, not a tool,
so the filter takes the place of the pin. A comment in `bin/hostctl`
says so.

The upstream site can still block a name that the user depends on,
such as `github.com` or the sockeye host. Do not add a list of names
that `hostctl` never blocks until a block like that happens.

## Fix

1. In `bin/hostctl`, download with `curl -fsS` to a file from
   `mktemp`. Stop before any write to `/etc/hosts` if the download
   fails.
2. Keep only lines of the form `0.0.0.0 <name>`, where `<name>` is a
   valid host name. Drop comments and every other line. Drop
   `localhost`, `broadcasthost`, and each `*.localhost` name.
3. Write the result of `custom_hosts_entries` first, with the
   `127.0.0.1 localhost` and `::1 localhost` lines, then the
   filtered list. Write the whole file with one `sudo install` or
   one `sudo tee`.
4. In `laptop.sh`, replace `mkdir -p "$HOME/.ssh"` with
   `install -d -m 700 "$HOME/.ssh"`, then run
   `chmod 700 "$HOME/.ssh"` to fix a directory that already exists.
5. Update the comments in `bin/hostctl` and `laptop.sh`. The
   `bin/hostctl` comment says that the filter is the only check on
   the download.

## Proof

- Put the filter in a function that reads a file and writes the
  result to stdout. Do not add a variable that changes the URL. A
  variable like that gives a new input control of a root write. Run
  the function on a local file that has `1.2.3.4 github.com`,
  `0.0.0.0 localhost`, `0.0.0.0 blog.localhost`, and a comment. The
  output has none of those lines, and its `localhost` lines come
  from the script.
- Turn off the network and run `bin/hostctl`. `/etc/hosts` does not
  change.
- Run `chmod 755 ~/.ssh`, then run `laptop.sh`. `stat -f %Lp ~/.ssh`
  prints `700`.

## Rollout

The `~/.ssh` fix changes nothing on the current workstation, where
`~/.ssh` and `$HOME` are already 0700. Close
`find_017Zhy1qDifSHkXc17yVN8M2` when the fix is on `main`. Close
`find_01JhxaaHcHsp4MRviPjJHTY5` after a run of `laptop.sh` writes a
filtered `/etc/hosts`.
