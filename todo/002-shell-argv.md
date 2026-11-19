# Pass untrusted text to a process as separate arguments

Open findings:

- `find_01VRecMzZV4q4YjrmDc1nR68` (high): the `K` map types the word
  under the cursor into `:grep` with no escaping.
- `find_01GtDCqv3FPX6Fr8Bvao8YqQ` (high): the SQL run map puts the
  first line of `.db` and the buffer path into a shell string.
- `find_01KmKkirjToBie4awYutbWgg` (high): `bin/replace` passes file
  names to `rg` with no `--`.

## Problem

Each finding builds one string, and a shell or an option parser reads
text from a repo as syntax. The user must press a key or run a command
on the hostile input.

Proven paths at `ed65118`:

- `vim/init.lua:157-158`: `K` runs
  `:silent grep! "\b<C-R><C-W>\b"`. `'shell'` is zsh
  (`vim/init.lua:24`). `$(...)` and backticks expand inside double
  quotes, and `"` ends the quotes. Ex also reads `|`, `%`, and `#` in
  the argument. The Neovim 0.12.6 runtime widens `'iskeyword'` to
  these characters: `ftplugin/forth.vim:18` sets `33-126,128-255`,
  and `ftplugin/8th.vim:25` and `ftplugin/reva.vim:26` include `"`,
  `$`, `(`, `)`, and `` ` ``.
- `vim/init.lua:505-517`: the callback reads `.db` from Neovim's
  working directory and runs
  `'psql -d "' .. dbname .. '" -f "' .. path .. '"'` through
  `vim.fn.systemlist`. The `-d` value can also be a full connection
  string, which sends the SQL file to a server that the repo author
  chooses.
- `bin/replace:20`: `rg -F -l -0 "$find_this" "$@"` has no `-e`
  before the pattern and no `--` before the paths. A file named like
  an `rg` option, matched by a glob such as `*`, becomes an option.

Sibling path that no finding names:

- `run_file` (`vim/init.lua:110-116`) puts `expand("%:p")` with no
  escaping into `:terminal`. The `<Leader>r` map in a Go buffer runs
  `go run` on repo code by design, so this path adds little harm.
  Fix it in the same change so that no string command stays.

## Fix

1. Change `K` to a Lua function. It runs
   `vim.system({ "rg", "--vimgrep", "-w", "-e", word, "--" })`,
   fills the quickfix list from the output, and opens it. No Ex
   parser and no shell reads the word.
2. In the SQL callback, check the `.db` line against `^[%w_]+$`.
   Stop with a message if it does not match. Run
   `vim.fn.systemlist({ "psql", "-d", dbname, "-f", path })`.
3. In `run_file`, build an argument list and pass it to
   `vim.fn.jobstart(argv, { term = true })` in a new split.
4. In `bin/replace`, run `rg -F -l -0 -e "$find_this" -- "$@"`. Run
   `xargs -0 sed -i '' -e "s/.../.../g" --`, so that a change to
   GNU `sed` keeps the paths as paths.
5. Optional: add a line to `Checkfile` that fails when `vim/init.lua`
   passes a concatenated string to `system`, `systemlist`, or
   `terminal`. Its cost is less than one second of CI.

## Proof

- Make a scratch buffer and run `:setlocal iskeyword=33-126`. Type a
  token that has `"`, `$(touch /tmp/k)`, backticks, `;`, and `|`.
  Press `K`. `/tmp/k` does not appear, and the quickfix list shows
  only literal matches.
- Write `x$(touch /tmp/q)` to `.db`. Press `<Leader>r` in a SQL
  buffer. The callback stops with a message, and `/tmp/q` does not
  appear. Do the same with a SQL file path that has `$(...)` in its
  name and a valid `.db`. `psql` gets the path as one argument.
- In a scratch directory, make a file named `--pre=./x` and an
  executable `x` that writes a marker. Run `replace a b *`. The
  marker does not appear.

## Open questions

- Hypothesis: Neovim maps `*.fth` to the `forth` filetype. Open a
  scratch `x.fth` and run `:set ft?` to decide it. The 8th and reva
  filetypes give the same path in both cases.
