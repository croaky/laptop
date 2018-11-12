# Configure and Use Tmux

This post describes a workflow
using a Unix shell, Tmux, and Vim.

In this workflow,
Tmux is used only for long-running processes.
It helps reduce cognitive load imposed by the
[administrative debris](http://2ndscale.com/rtomayko/2008/administrative-debris)
of open tabs, panes, or windows.

## Install

Install Tmux and read the documentation:

```
brew install tmux
man tmux
```

## Configure

See [this `tmux.conf` example][c].
It:

[c]: https://github.com/statusok/statusok/blob/master/dotfiles/shell/tmux.conf

* includes a light color scheme
* changes default `Ctrl+b` "prefix" to `Ctrl+a` (like GNU `screen`)
* includes Vim-like bindings
  for movement between windows (`Ctrl+a h`, `Ctrl+a j`, etc.)

## Start Tmux session

`tat` (short for "tmux attach") is a command from
[statusok/dotfiles](https://github.com/statusok/statusok/blob/master/bin/tat)
that names the tmux session after the project's directory name.

```
cd project-name
tat
```

At this point, `tat` is the same thing as:

```
tmux new -s `basename $PWD`
```

## Run long-running processes in Tmux

Run the app's [processes with a process manager][ps].

[ps]: /process-model

```
foreman start
```

The processes managed by Foreman are long-running.

## Perform ad-hoc tasks outside Tmux

After only running one command inside Tmux, detach:

```
Ctrl+a d
```

Back in a shell, perform ad-hoc tasks such as:

```
git status
git add --patch
git commit --verbose
```

These are quick commands,
focused on the immediate task at hand.

## Do most work in Vim

A large portion of work is done from within a text editor:

* editing text
* [searching for text](search-with-vim)
* [wrapping text](wrap-text-in-vim)
* [sorting lines](sort-lines-in-vim)
* [running specs](run-specs-with-vim)
* [checking spelling](spell-check-in-vim)
* etc.

```
vim .
```

## Suspend the Vim process

To return control from Vim to the command line,
suspend the process:

```
Ctrl+z
```

See suspended processes for this shell:

```
jobs
```

It will output something like:

```
[1]  + suspended  vim spec/models/user_spec.rb
```

We might do more ad-hoc work:

```
git fetch origin
git rebase -i origin/master
git diff --stat origin/master
```

When ready to edit in Vim again, foreground the process:

```
fg
```

## Re-attach to Tmux

To observe process logs,
stop or start long-running processes,
re-attach:

```
tat
```

At this point, `tat` is the same thing as:

```
tmux attach -t `basename $PWD`
```

Compared to other Tmux workflows,
this workflow involves more attaching and detaching from sessions.
That is why the `tat` shortcut is valuable.

## Scroll

Enter "copy mode":

```
prefix+[
```

Use Vim-like bindings to page up and down:

```
Ctrl+b
Ctrl+f
```

## Navigate between windows

Create a window:

```
Ctrl+a c
```

Move to window 1:

```
Ctrl+a 1
```

Move to window 2:

```
Ctrl+a 2
```

Kill a window:

```
Ctrl+a x
```

## Detach and return later

Detach:

```
Ctrl+a d
```

Take a break, go home, or move on to another project.

The next time the machine is used,
a distraction-free environment is available for primary tasks.
Meanwhile, Tmux handles one responsibility:
quietly managing long-running processes.
