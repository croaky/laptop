# Replace the npm language servers

Node is installed here for three things, and none of them is a
JavaScript project. Two are language servers published only as npm
packages, `bash-language-server` and `vscode-langservers-extracted`.
The third is nvim-treesitter, whose install-time `tree-sitter generate`
runs node to read a `grammar.js` unless told otherwise. Everything else
went native already: Go builds JavaScript through esbuild's Go API,
`tsgo` typechecks it, `dprint` formats it.

If all three go, node and npm come off the machine, along with
`~/.npmrc` and the `js/` directory.

## What is actually enabled

`vim/init.lua` enables two servers, `bashls` and `html`. No `cssls`, no
`jsonls`, no `eslint`. So `vscode-langservers-extracted` is a large
package installed for the one `vscode-html-language-server` binary
inside it.

## What each one is worth

`bashls` is the one that costs something to lose. It runs shellcheck
internally, and it is the only diagnostics source configured for shell:
there is no `nvim-lint` here, so without it shellcheck stops being live
and only runs when invoked. Hover on commands and flags, completion,
and go-to-definition on functions and sourced files go with it.
`shfmt` through conform and the treesitter highlighting are separate
and unaffected.

`html` costs much less. Most markup is `.hml`, which has its own
grammar and no language server, so `html` only attaches to plain
`.html` buffers. What goes is tag and attribute completion and hover on
those files. dprint's markup_fmt formats them either way.

## Candidates

- Shell diagnostics: `nvim-lint` calling the `shellcheck` binary
  Homebrew already installs. That covers the part of `bashls` worth
  keeping, and gives up hover and completion.
- HTML: `superhtml`, a single Zig binary that is both a language server
  and a formatter. Available through `ubi`, which is already installed.
- nvim-treesitter: export `TREE_SITTER_JS_RUNTIME=native` in
  `shell/zshrc`. The CLI honors it, and it is the same QuickJS a
  grammar's own `grammar` check already uses through
  `--js-runtime native`.

## Unverified

None of these has been tried here. Before committing to this:

- Does `nvim-lint` with shellcheck report on the same buffers and with
  the same severities that `bashls` did, and does it respect a
  `.shellcheckrc`?
- Does `superhtml` attach cleanly under `vim.lsp.config`, and is its
  diagnostic set useful or noisy on real files?
- Does nvim-treesitter's install path actually read
  `TREE_SITTER_JS_RUNTIME`, or does it call the CLI in a way that skips
  the environment? Test by removing node and reinstalling a parser from
  scratch.

The order matters: prove the treesitter env var first, since that one
is a single line and blocks nothing. The two servers can be swapped one
at a time after.
