# Plans

`todo/` holds the plans. A numbered plan is next work, in the order
below. A plan groups the claudesec findings that one change closes,
not one plan for each finding. Each plan lists its open finding IDs
and the sibling code paths that no finding names yet.

## Threat model

The workstation user is trusted. These sources are not trusted:

- The content of a cloned repo.
- The content of a sockeye change that somebody else pushed and that
  `co` or `createtree` opens.
- A file that a script downloads from a URL that can change.

A plan judges a finding by its attacker, its consequence, and its
boundary. A structural change does not close a finding by
association. Close a finding only when its fix criteria are met in
source and the workstation runs the new code: a `git pull` in
`~/laptop`, a new shell, a restarted Neovim, and a new run of
`laptop.sh` where the fix is in that script.

## Order

A path that runs repo code with no action from the user, other than
opening a directory, comes first. A path that needs a key press or a
command on a hostile input comes next. A path that needs the upstream
site or another local account comes last.

No numbered plan is open. Plans 002 and 003 shipped. Their text is in
`git log -- todo/002-shell-argv.md todo/003-laptop-sh-state.md`.

Plan 001 shipped as the change that added `bin/git-trust`. Its text is
in `git log -- todo/001-repo-trust.md`. A plan that starts a program
from Neovim or the shell keeps its rule: no relative `PATH` entry, and
repo-chosen code only in a repo that `git trust --check` accepts.

## Accepted risks

- `git trust` covers each worktree of the trusted repo. So it trusts
  every person who can push a change to that repo, not only the user.
  The user accepted this on 2026-11-19. Without it, each new change
  worktree needs its own trust step. `README.md` and `bin/git-trust`
  say this to each person who runs `git trust`.
- The hosts list site can block any name, also one that the user
  needs, such as `github.com` or the sockeye host. `bin/hostctl`
  cannot tell a wanted name from an ad name. The user accepted this
  on 2026-11-19, with no allow list until a block like that happens.
  `hostctl --unblock` undoes a block at once.

## Checked paths

No finding names these paths. On 2026-11-19 a direct test showed
that none of them runs code that a repo chooses, so none needs a plan.
Repeat a test when the named program changes.

- The prompt runs `git current-branch`, which runs only
  `git rev-parse`. A repo whose `.git/config` sets `core.fsmonitor`
  to a marker script did not start the script when the prompt ran.
  `git status` did start it, but only when the user runs it.
- In a module whose `go` line names a newer Go, `go list -m` in
  `bin/goimportslocal` tries to download that Go release. Go gets it
  only from the official `golang.org/toolchain` module, which the
  checksum database verifies. With `GOTOOLCHAIN=auto`, Go never picks
  a release older than the local one. So the download is not repo
  code. `go env` does not download a release.
- gopls runs `go list -compiled`, which reads cgo directives. Go
  rejects `#cgo CFLAGS: -fplugin=...` as an invalid flag. Go puts the
  names from `#cgo pkg-config` after `--`, so `pkg-config` reads them
  as package names. `pkg-config` itself comes from the absolute
  `PATH`, not from the repo.
