# ~/.gitignore

Set a `.gitignore` file to apply across all projects on a local machine with:

```
git config --global core.excludesfile ~/.gitignore
```

My current contents of ~/.gitignore are:

```
!tags/
!tmp/cache/.keep
*.pyc
*.sw[nop]
.DS_Store
.bundle
.byebug_history
.env
db/*.sqlite3
log/*.log
rerun.txt
tags
tmp/**/*
```

Consider the pattern that catches files with `.swp` extensions:
It ignores temporary files created by Vim.

Those files could be ignored in each project but
not every teammate on every project is also using Vim.
For them, that line is unnecessary.

> "Programming at its best is an act of empathy." - [Kent
> Beck](http://rubyrogues.com/023-rr-book-club-smalltalk-best-practice-patterns-with-kent-beck/)
