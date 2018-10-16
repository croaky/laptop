# Tmux Only for Long Running Processes

This post describes a minimal tmux workflow, used only for long-running
processes. It is intended to reduce the cognitive load imposed by
[administrative debris](http://2ndscale.com/rtomayko/2008/administrative-debris)
of open tabs, panes, or windows.

## Set up tmux for a Rails project

From within a full-screen shell (to hide window chrome, status bars,
notifications, the system clock, and other distractions), create a tmux session
for a Rails project:

```bash
cd project-name
tat
```

`tat` (short for "tmux attach") is a command from
[thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles/blob/master/bin/tat)
that names the tmux session after the project's directory name. That naming
convention will help us re-attach to the session later using the same `tat`
command.

At this point, `tat` is the same thing as:

```bash
tmux new -s `basename $PWD`
```

Run the Rails app's [web and background processes with Foreman][ps].

[ps]: /process-model

```bash
foreman start
```

The process manager is a long-running process. It is therefore a great candidate
for tmux. Run it inside tmux, then forget it.

After only running one command inside tmux, detach immediately:

```bash
<tmux-prefix> d
```

`Ctrl+b` is the default [tmux prefix]. Many people change it to be `Ctrl+a` to
match the API provided by GNU Screen, another popular terminal multiplexer.

[tmux prefix]: tmux-faq

## Perform ad-hoc tasks

Back in a full-screen shell, we perform ad-hoc tasks such as:

```bash
vim .
git status
git add --patch
git commit --verbose
```

Those commands are targeted, "right now" actions. They are executed in a split
second and focus us immediately on the task at hand.

## Doing most of the work from inside Vim

A majority of our work is done from within a text editor,
such as [searching with Vim][search]:

[search]: fast-search-with-vim

```bash
\ string-i-am-searching-for
```

Or, [running specs with Vim][specs]

[specs]: run-specs-with-vim

```bash
<Leader> s
```

In thoughtbot/dotfiles, `<Leader>` is `<Space>`.

## Suspending the Vim process when necessary

To return control from Vim to the command line, suspend the process:

```bash
Ctrl+z
```

Run this command to see suspended processes for this shell session:

```bash
jobs
```

It will output something like:

```bash
[1]  + suspended  vim spec/models/user_spec.rb
```

This is when we might do some Git work:

```bash
git fetch origin
git rebase -i origin/master
git push --force origin <branch-name>
git log origin/master..<branch-name>
git diff --stat origin/master
git checkout master
git merge <branch-name> --ff-only
git push
git push origin --delete <branch-name>
git branch --delete <branch-name>
```

When we're ready to edit in Vim again, we foreground the process:

```bash
fg
```

## Re-attach to the tmux session quickly

When we need to restart the process manager or start a new long-running
process, we re-attach to the tmux session:

```bash
tat
```

At this point, `tat` is the same thing as:

```bash
tmux attach -t `basename $PWD`
```

Compared to other tmux workflows, this workflow involves more attaching and
detaching from tmux sessions. That is why the `tat` shortcut is valuable.

Back inside tmux, we can kill the Foreman process:

```bash
Ctrl+c
```

Or, we might want to open a long-running Rails console in order to maintain a
history of queries:

```bash
<tmux-prefix> c
rails console
```

After poking around in the database, we might detach from tmux again:

```bash
<tmux-prefix> d
```

## Get things done

At that point, we might take a break, go home, or move on to another project.

The next time we sit (or [stand](http://en.wikipedia.org/wiki/Standing_desk)!)
at our desks, we start fresh by creating a branch, opening Vim, or doing
whatever ad-hoc task is necessary in a clean slate, distraction-free
environment.

Meanwhile, tmux handles one responsibility for us: quietly managing long-running
processes.
