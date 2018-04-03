# Update a GitHub Fork

A typical flow when contributing to open source software on GitHub is:

* Fork project to personal account
* Work on fork
* Keep fork updated with "upstream" changes in main project

For example, one time:

```
git clone git@github.com:croaky/dotfiles.git
cd dotfiles
git remote add upstream git@github.com:thoughtbot/dotfiles.git
```

On each update, from the local forked `master` branch:

```
git fetch upstream
git rebase upstream/master
```

The goal of the rebase is to have a cleaner history
if there are local commits in the forked repo.
