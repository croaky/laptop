# Laptop

Set up a macOS machine as a software development environment.

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

Done!
The script can safely be run multiple times.
It is tested on the latest version of macOS on a arm64 (Apple Silicon) chip.

The following items are not part of the script.
They are "one time setup" items.

## Keyboard

Configure "System Preferences > Keyboard":

- Set "Key Repeat" to "Fast".
- Set "Delay Until Repeat" to "Short".
- Set "Modifier Keys > Caps Lock Key" to "^ Control".

## 1.1.1.1 as DNS resolver

Set DNS resolver to [`1.1.1.1`](https://1.1.1.1),
a [fast, privacy-focused](https://blog.cloudflare.com/announcing-1111/)
DNS service from Cloudflare:

- Go to "System Preferences > Network > Advanced... > DNS"
- Click "+"
- Enter "1.1.1.1"
- Click "OK"
- Click "Apply"

## macOS apps

Install macOS apps:

- [Magnet.app](https://apps.apple.com/us/app/magnet/id441258766?mt=12)
- [Postgres.app](https://postgresapp.com/)

## SSH key with Ed25519

Ed25519 uses elliptic curve cryptography
with good security and performance.
When a whole team uses Ed25519,
a server's `~/.ssh/authorized_keys` file looks nice:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAePksB5aPc6sww+RMzJwpVuDhRAgzOKP1Q/o3suIbw alice@home.local
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEB/O/VwAvqWIV/EN9aHjHAg/9JYsX/Ce2yvr5wPI3gZ bob@work.local
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYG1rgF4YSSBwtinbhFLR/Qeah11jYcQpf6lX4yql60 carol@home.local
```

Create the key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$(whoami)@$(hostname)"
```

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Update `~/.ssh/config`:

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

Host github.com
  Hostname ssh.github.com
  Port 443
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

## Binary malware scans

A macOS feature that scans new binaries for malware
adds an extra ~2s on to every build of Go programs,
disturbing its fast iteration cycle. Disable it by running:

```
sudo spctl developer-mode enable-terminal
```

Then:

- Go to "System Preferences > Privacy & Security > Developer Tools"
- Select [kitty](https://sw.kovidgoyal.net/kitty/) as the terminal program.
