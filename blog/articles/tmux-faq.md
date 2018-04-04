# Tmux FAQ

Getting started with tmux, these are the questions I've had.

## How do I get started

Install tmux, read the documentation, and fire it up:

```
brew install tmux
man tmux
tmux -u
```

## Can I make the environment look good?

Yes. See these lines in `tmux.conf` of [statusok/dotfiles][c].

[c]: https://github.com/statusok/statusok/blob/master/dotfiles/shell/tmux.conf

```
# improve colors
set -g default-terminal "screen-256color"

# soften status bar color from harsh green to light gray
set -g status-bg '#666666'
set -g status-fg '#aaaaaa'

# remove administrative debris (session name, hostname, time) in status bar
set -g status-left ''
set -g status-right ''
```

## What's a prefix?

The "prefix" namespaces tmux commands.
By default it is `Ctrl+b`.
In our `tmux.conf` in `thoughtbot/dotfiles`, we bound it to `Ctrl+a`:

```
# act like GNU screen
unbind C-b
set -g prefix C-a
```

## How can I scroll up to see my backtraces?

Enter "copy mode":

```
prefix+[
```

Use Vim bindings to page up and down:

```
Ctrl+b
Ctrl+f
```

## How can I copy text?

Add this to your `tmux.conf`:

```
# enable copy-paste http://goo.gl/DN82E
set -g default-command "reattach-to-user-namespace -l zsh"
```

## How can I make tmux act more like Vim?

Add this to your `tmux.conf`
to use Vim's home-row keys for movement between windows and panes:

```
# act like vim
setw -g mode-keys vi
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind-key -r C-h select-window -t :-
bind-key -r C-l select-window -t :+
```

## How do I name sessions?

I'd like to name my tmux sessions so I can leave one,
drop into another,
and go back to the original with all my state maintained
(files still open in my editor, console/logs I want open, etc.).

Create a new session:

```
tmux new -s airbrake
```

Attach to a session:

```
tmux attach -t airbrake
```

## How do I split and move between windows?

Create a window:

```
prefix c
```

Move to window 1:

```
prefix 1
```

Move to window 2:

```
prefix 2
```

Kill a window:

```
prefix x
```

## How do I reload `~/.tmux.conf`?

After editing `~/.tmux.conf`, execute this from a shell:

```
tmux source-file ~/.tmux.conf
```

Give tmux a shot!
