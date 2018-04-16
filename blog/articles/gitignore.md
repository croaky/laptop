# ~/.gitignore

Set a `.gitignore` file to apply across all projects on a local machine with:

```
git config --global core.excludesfile ~/.gitignore
```

The contents of the [Status OK monorepo's
gitignore](https://github.com/statusok/statusok/blob/master/dotfiles/git/gitignore)
are:

```
!tags/
!tmp/cache/.keep
*.pyc
*.sw[nop]
.DS_Store
.bundle
.byebug_history
db/*.sqlite3
log/*.log
rerun.txt
tags
tmp/**/*
```

One example pattern is the line matching files with `.swp` extensions:
It ignores temporary files created by Vim.

Those files could be ignored in each project but
not every teammate on every project is also using Vim.
For them, that line is unnecessary.
