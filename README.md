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
It is tested on the latest version of macOS on a arm64 (Apple Silicon) chip.

Separate from the script, the following README sections
are "one time setup" items.

## macOS apps

Install macOS apps:

- [Arc](https://arc.net/download)
- [Magnet](https://apps.apple.com/us/app/magnet/id441258766?mt=12)
- [Postgres](https://postgresapp.com/)

## Keyboard

Configure "System Preferences > Keyboard":

- Set "Key Repeat" to "Fast".
- Set "Delay Until Repeat" to "Short".
- Set "Modifier Keys > Caps Lock Key" to "^ Control".

## 1.1.1.1 as DNS resolver

Set DNS resolver to [`1.1.1.1`](https://1.1.1.1),
a fast, privacy-focused DNS service from Cloudflare:

- Go to "System Preferences > Network > Advanced... > DNS"
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

- Go to "System Preferences > Privacy & Security > Developer Tools"
- Select "Ghostty" as the terminal program.
