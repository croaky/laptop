# Laptop

Set up a macOS machine as a software development environment.

## SSH key

Ed25519 uses elliptic curve cryptography
with good security and performance.

Create the key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$(whoami)@$(hostname)"
```

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Add the private key to the SSH agent on macOS:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Copy the public key to macOS clipboard:

```bash
cat ~/.ssh/id_ed25519.pub | pbcopy
```

[Upload the public key to GitHub](https://github.com/settings/keys).

## Git

Set your Git and GitHub user in `~/.gitconfig.local`
to keep it out of version control:

```
[github]
  user = yourgithubusername
[user]
  name = Your Name
  email = you@example.com
```

### Change worktrees

`createtree`, `mergetree`, and `closetree` use `soc` when origin
matches a configured sockeye server. For other repos, they use
`git create-tree`. `co <change-id>` changes directory to the worktree
of a change.

Install `soc` with `go install ./cmd/soc` from a clone of sockeye.
Run `soc help` for the commands. The sockeye source has the details.

Name each server in `~/.gitconfig.local`:

```gitconfig
[sockeye]
  url = https://personal.example.com
[sockeye "personal"]
  url = https://personal.example.com
[sockeye "work"]
  url = https://work.example.com
```

Then run `soc git setup` and `soc login`.
`~/.gitconfig` is a symlink to `git/gitconfig`, which this repo tracks.
Move what `soc` writes there, such as a `credential` block, to
`~/.gitconfig.local`. `git/gitconfig` includes that file.

## Install

Clone onto laptop:

```
export LAPTOP="$HOME/laptop"
git clone https://github.com/croaky/laptop.git $LAPTOP
cd $LAPTOP
```

Review:

```
less laptop.sh
```

Run:

```
./laptop.sh
```

The script can safely be run multiple times.
It is tested on the latest version of macOS on an arm64 (Apple Silicon) chip.

The script links the dotfiles to the main clone, `~/laptop`,
also when it runs from a change worktree.
So a test run from a worktree is safe after `mergetree` deletes it.
A change to a dotfile, such as `shell/zshrc`,
takes effect after the merge and a `git pull` in `~/laptop`.

### Hot corners

`laptop.sh` turns off all four hot corners.
A hot corner set to Mission Control opens
when a drag crosses a display corner,
and a dragged screenshot then cannot reach its window.
The F3 key still opens Mission Control.
To use a hot corner, set it in
"System Settings > Desktop & Dock > Hot Corners".
The next run of `laptop.sh` turns it off again.

### Click wallpaper to reveal desktop

`laptop.sh` turns off "Click wallpaper to reveal desktop".
When this setting is on, a click on the wallpaper
moves all windows to the screen edges.
A screenshot drag that starts or crosses the wallpaper can do this,
and the target window then moves away.
To turn it on, set it in
"System Settings > Desktop & Dock".
The next run of `laptop.sh` turns it off again.

### Window shortcuts

`laptop.sh` sets three shortcuts for the
"Window > Move & Resize" menu in every app:

- Control-Option-Left: "Left" (left half)
- Control-Option-Right: "Right" (right half)
- Control-Option-Return: "Fill" (full screen area)

An app reads the shortcuts when it starts.
Quit and reopen an app that runs, or log out and in.
"Fill" does not go back to the old size.
Use "Window > Move & Resize > Return to Previous Size" for that.
To see or change the shortcuts, go to
"System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts".

Separate from the script, the following README sections
are "one time setup" items.

## macOS apps

Install macOS apps:

- [Warp](https://www.warp.dev/)

## Keyboard

Configure "System Settings > Keyboard":

- Set "Key Repeat" to "Fast".
- Set "Delay Until Repeat" to "Short".
- Set "Modifier Keys > Caps Lock Key" to "^ Control".

Disable "Press and Hold" accent menu
to allow key repeat for all keys:

```bash
defaults write -g ApplePressAndHoldEnabled -bool false
```

## 1.1.1.1 as DNS resolver

Set DNS resolver to [`1.1.1.1`](https://1.1.1.1),
a fast, privacy-focused DNS service from Cloudflare:

- Go to "System Settings > Network > Advanced... > DNS"
- Click "+"
- Enter "1.1.1.1"
- Click "OK"
- Click "Apply"

## Binary malware scans

A macOS feature that scans new binaries for malware
adds an extra ~2s on to every build of Go programs,
disturbing its fast iteration cycle. Disable it by running:

```
sudo spctl developer-mode enable-terminal
```

Then:

- Go to "System Settings > Privacy & Security > Developer Tools"
- Select "Warp" as the terminal program.
