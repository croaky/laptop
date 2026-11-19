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

2. `002-shell-argv.md`: pass untrusted text to a process as separate
   arguments, not as one shell string. It covers the `K` map, the SQL
   run map, and `bin/replace`.
3. `003-laptop-sh-state.md`: validate what `laptop.sh` writes to
   `/etc/hosts` and `~/.ssh`.

Plans 002 and 003 share no file with each other, so they can run in
parallel. The line numbers in each plan are from commit `ed65118`.

Plan 001 shipped as the change that added `bin/git-trust`. Its text is
in `git log -- todo/001-repo-trust.md`. A plan that starts a program
from Neovim or the shell keeps its rule: no relative `PATH` entry, and
repo-chosen code only in a repo that `git trust --check` accepts.
