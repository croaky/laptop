# .gitignore

Configure `~/.gitignore` for all projects on a machine
and `project/.gitignore` for local overrides.

[Example](https://github.com/statusok/statusok/blob/master/dotfiles/git/gitignore):

```
*.lock
*.log
*.pyc
*.sw[nop]
.DS_Store
.bundle
node_modules
public
tmp
vendor
```

Directories and files matching these patterns will be ignored for
[Git](https://git-scm.com/docs/gitignore) commits.

They will also ignored for
[ag](https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage)
or [fzf](https://github.com/junegunn/fzf#respecting-gitignore)
searches.
