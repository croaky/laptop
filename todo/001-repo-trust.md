# Trust the code that a repo chooses only by a user decision

Open findings:

- `find_01AyNucE8Nx2gCTFbQxCvQXo` (high): `shell/zshrc` puts the
  relative `./bin` first on `PATH`, and the prompt runs `git`.
- `find_01Rykx4rPHCyLVgndUcNBQqN` (high): format-on-save runs a
  project `node_modules/.bin/dprint` and reads a project dprint
  config.
- `find_013CnoDLsTc9uji1v3V2GvN9` (high): format-on-save runs
  `go tool goimports` and `go tool pgfmt` as the repo's `go.mod`
  resolves them.

## Problem

In each finding, a file in the working tree decides which program
runs as the workstation user. The user only opens a directory or
saves a file. The attacker can be the author of a public repo, or a
person who pushes a change to a shared sockeye server.

Proven paths at `ed65118`:

- `shell/zshrc:137` puts `./bin` before every other directory on
  `PATH`. `git_prompt_info` (`shell/zshrc:39-44`) runs
  `git current-branch` at each prompt, so a repo's `bin/git` or
  `bin/git-current-branch` runs when the prompt draws.
  `soc completion zsh` (`shell/zshrc:141-143`) runs `soc` by bare
  name when a shell starts, and the shell sources its output.
- conform.nvim at the locked commit `016802d` defines `dprint` with
  `command = util.from_node_modules("dprint")`. That function looks
  for `node_modules/.bin/dprint` in each parent directory before it
  uses `PATH`. The same definition sets `cwd` to the directory of the
  nearest `dprint.json`. `vim/init.lua:316-332` maps eight filetypes
  to `dprint`, and `vim/init.lua:334-351` does not replace the stock
  definition.
- `bin/goimportslocal:43-46` selects `go tool goimports` when a
  substring occurs anywhere in `tools.mod` or `go.mod`. `go tool`
  then builds what the module's `tool`, `require`, and `replace`
  lines name. `pinsPgfmt` (`vim/init.lua:296-307`) makes the same
  substring test for `go tool pgfmt` (`vim/init.lua:342-347`).

Sibling paths that no finding names:

- `_G.get_user` (`vim/init.lua:118-133`) runs `git config` by bare
  name. `statusline` (`vim/init.lua:556`) calls it at each redraw.
  Neovim gets `PATH` from the shell, so a repo's `bin/git` runs when
  Neovim opens in that repo.
- conform runs `goimportslocal` (`vim/init.lua:338`) and `go`
  (`vim/init.lua:343`) by bare name. The LSP configs run `bashd`,
  `tsgo`, and gopls by bare name. A fix to `go tool` alone leaves
  `./bin/goimportslocal` in front of the real script.
- `bin/goimportslocal:49` runs `go install` with no version when
  `goimports` is not on `PATH`. Inside a module, that build follows
  the module's `replace` lines and puts the result in `~/go/bin`.
  It does not run on a machine where `laptop.sh` has installed the
  pinned `goimports`.

## Decision

On 2026-11-19 the user decided to drop the project `bin` from `PATH`
and not to keep it for trusted repos. The shell history calls a
project script by its `./bin/` path 305 times and by a bare name 2
times. The Checkfiles call `./bin/lint` and `./bin/gotest-traced` by
path. No script in a project `bin/` calls a sibling script by bare
name. A user now types `./bin/gotest` where `gotest` worked before.

So zsh does not read the trust store. Its only reader is in
`vim/init.lua`.

## Fix

1. Remove `./bin` from `shell/zshrc:137`. Add no hook that puts a
   project directory on `PATH`.
2. Keep the trust store outside every repo: a multi-valued key, for
   example `laptop.trusted`, in `~/.gitconfig.local`. Each value is
   an absolute repo root. No repo can write that file. Add a short
   command in `bin/` that adds the current repo root.
3. In `vim/init.lua`, add one Lua function that reads the trust store
   and answers for a buffer's repo root. Use it for each formatter
   that a repo can change. It is the only reader of the trust store.
4. Override the `dprint` formatter. Run `~/.local/bin/dprint` by
   absolute path. In an untrusted repo, pass
   `--config ~/.config/dprint/dprint.jsonc` and set `cwd` outside the
   project.
5. In an untrusted repo, `goimportslocal` runs `~/go/bin/goimports`,
   which `laptop.sh` pins. In a trusted repo, it keeps `go tool`.
   Remove the unversioned `go install` at `bin/goimportslocal:49`,
   and fail with a message in its place.
6. In an untrusted repo, the `sql` formatter list is empty. In a
   trusted repo, `pinsPgfmt` keeps `go tool pgfmt`.
7. Start the programs that Neovim runs with no user action by
   absolute path: `git` in `_G.get_user`, `goimportslocal`, `go`,
   and the LSP commands.
8. Update `README.md` and the comments in `shell/zshrc` and
   `vim/init.lua`. Say what trust means and how to trust a repo. Say
   that a project script runs by its `./bin/` path.

## Proof

Make a scratch repo that has executable `bin/git`,
`bin/git-current-branch`, `bin/soc`, `bin/goimportslocal`, and
`node_modules/.bin/dprint`. Each file writes a marker file. Add a
`go.mod` that names the goimports pin in a comment and has a
`replace` of `golang.org/x/tools` to a local directory. Add a
`dprint.json` that lists a local process plugin.

In that repo, untrusted:

- Open a shell, draw a prompt, and start Neovim.
- Save a `.go`, a `.md`, and a `.sql` file.
- No marker file appears.

Trust the repo, and do the same steps. Only the `go tool` and the
project dprint config take effect. The project `bin` files still do
not run.

## Open questions

- Hypothesis: dprint 0.55.2 loads a process plugin from a project
  config with no prompt. The scratch repo above decides it. Step 4
  closes the path in both cases.
- Hypothesis: `~/.gitconfig.local` still sets the credential helper
  `!soc auth git-credential` by bare name. Commit `089bcd6` removed
  that text from `README.md`. Run
  `git config --get-regexp '^credential'` to decide it. Without
  `./bin` on `PATH`, the bare name resolves to the installed `soc`.
- Hypothesis: macOS `sudo` keeps the user's `PATH`. `sudo -n -l`
  showed no `secure_path`. Step 1 removes the path in both cases.
