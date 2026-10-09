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

`createtree` uses `soc checkout` when origin matches a configured
sockeye server, and `git create-tree` for other repos. `mergetree` and
`closetree` use the same server selection.

Keep instance URLs in `~/.gitconfig.local`:

```gitconfig
[sockeye]
  url = https://personal.example.com
[sockeye "dc"]
  url = https://personal.example.com
[sockeye "ivp"]
  url = https://work.example.com
```

`soc login` and `soc git setup` write the `credential` block for a
server to `~/.gitconfig`, which this repo does not track. After you
log in, move that block to `~/.gitconfig.local`. `git/gitconfig`
includes that file.

```gitconfig
[credential "https://personal.example.com"]
  helper =
  helper = !soc auth git-credential
```

The token is in `~/.config/sockeye/token`. The Keychain has no copy.
The `credential` block sends git to `soc auth git-credential` for the
token. The empty `helper` clears the `osxkeychain` helper in
`git/gitconfig`. GitHub uses `gh` the same way. Other hosts use the
Apple-signed `osxkeychain` helper.

`soc-dc` and `soc-ivp` select an instance for one command, such as
`soc-ivp login` or `soc-dc show SOC-1`. They do not change the saved
default. An explicit checkout still needs a clone from that instance.

Tree helpers select origin's server even when `SOCKEYE_URL` names
another server. Register each server before using its tree helpers.

Run the isolated helper tests with `zsh -f shell/zshrc_test.zsh`.
The tests use local stub commands and do not contact a server.

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

Separate from the script, the following README sections
are "one time setup" items.

## macOS apps

Install macOS apps:

- [Arc](https://arc.net/download)
- [Magnet](https://apps.apple.com/us/app/magnet/id441258766?mt=12)
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
