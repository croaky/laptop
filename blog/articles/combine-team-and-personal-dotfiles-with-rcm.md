# Combine Team and Personal Dotfiles with rcm

Our team has a set of dotfiles at [thoughtbot/dotfiles][company]. They
contain vim, git, zsh, and tmux configuration that many of us use every day.

[company]: https://github.com/thoughtbot/dotfiles

Each of us also have personal sets of dotfiles. They augment our team dotfiles
with configuration such as aliases for our personal workflow, our name and email
for git, and vim syntax highlighting for languages such as Go or Elixir that
we aren't using yet on client projects.

We recently [released rcm][announce] which, among other things, allows a
workflow where those two sets of dotfiles co-exist in harmony.

[announce]: https://robots.thoughtbot.com/rcm-for-rc-files-in-dotfiles-repos

## Team dotfiles as primary

The team's dotfiles could be considered the primary dotfiles repo. It is
well-vetted and we can depend on it matching the latest conventions and
practices agreed upon by our team.

```
mkdir thoughtbot
cd thoughtbot
git clone https://github.com/thoughtbot/dotfiles.git
```

Note the directory convention is to keep local git repos matching the
`{user,organization}/project` GitHub structure, which also matches a [Go
convention][go].

[go]: http://golang.org/doc/code.html#PackagePaths

Once we have our team dotfiles cloned, we should install rcm. On OS X, we can
use the [Brewfile][brewfile]:

[brewfile]: https://robots.thoughtbot.com/brewfile-a-gemfile-but-for-homebrew

```
brew bundle dotfiles/Brewfile
```

See [the docs][install] to install on other platforms.

[install]: https://github.com/thoughtbot/rcm#installation

Next, we use rcm's `rcup` command to symlink files from thoughtbot/dotfiles to
`~/.aliases`, `~/.gitconfig`, `~/.psqlrc`, `~/.tmux.conf`, `~/.vimrc`,
`~/.zshrc`, and others:

```
rcup -d dotfiles -x README.md -x LICENSE -x Brewfile
```

The `-x` options, which exclude the `README.md`, `LICENSE`, and `Brewfile`
files, are needed during installation but can be skipped during future `rcup`
updates because we are symlinking the `~/.rcrc` file during installation, which
knows to exclude those files.

If we reload our shell at this point, we'd now have all the great features from
thoughtbot/dotfiles available to us. The most obvious immediate change would be
the look of our prompt.

## Personal dotfiles as secondary

Now, we need our personal dotfiles, for example [croaky/dotfiles][personal]:

[personal]: https://github.com/croaky/dotfiles

```
mkdir croaky
cd croaky
git clone https://github.com/croaky/dotfiles.git
rcup -d dotfiles -x README.md
```

That's it! Our two sets of dotfiles are living in harmony. But how does it work?

## The `.local` convention

At the end of the files we symlinked from thoughtbot/dotfiles are lines such as
this in `~/.zshrc`:

```
# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

Or this in `~/.vimrc`:

```vim
" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
```

These lines say "now, look for a file of the same name as myself, but with an
extra `.local` extension." This convention makes it clean to have a second set
of dotfiles around without one trampling on the other.

Most of the files we have in personal dotfiles end in `.local`. They are
additive to the team dotfiles, which is why it can help to think of the
personal dotfiles as "secondary."

## Overwrite

In some cases, the `.local` convention isn't available, so we need to
completely overwrite the file.

For example, if we use the `fail-fast` option in our personal `rspec`
config but it is not popular amongst the team, it is inappropriate to
live in the team dotfiles, which should represent only a reasonable subset that
is valuable for everyone.

In that example, when we next update team dotfiles, rcm asks if we want to
overwrite the file:

```
rcup -d dotfiles
overwrite /Users/croaky/.rspec? [ynaq] n
```

This demonstrates how rcm lets us pick a winner, and prefer our personal
preference in this case.

## Summary

We recommend creating and evolving a set of team dotfiles. We can each learn
many workflow tips from our teammates in [team dotfiles pull requests][pr].

[pr]: https://github.com/thoughtbot/dotfiles/pulls

With rcm's ability to manage both team and personal dotfiles together, there's
no reason to be afraid of using team dotfiles, because we can always override
the decisions in our personal set.
