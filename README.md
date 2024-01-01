# Laptop

Dotfiles and an install/update script:

```
export LAPTOP="$HOME/laptop"
git clone https://github.com/croaky/laptop.git $LAPTOP
cd $LAPTOP
./laptop.sh
```

Done!

The following items are not part of the script.
They are "one time setup" items.

## Keyboard

Configure "System Preferences > Keyboard":

- Set "Key Repeat" to "Fast".
- Set "Delay Until Repeat" to "Short".
- Set "Modifier Keys > Caps Lock Key" to "^ Control".

## macOS apps

Install macOS apps:

- [Magnet.app](https://apps.apple.com/us/app/magnet/id441258766?mt=12)
- [Postgres.app](https://postgresapp.com/)

## SSH key

[Create an SSH key](https://dancroak.com/ssh-ed25519)
and upload it to GitHub.

## Binary malware scans

A macOS feature that scans new binaries for malware
adds an extra ~2s on to every build of Go programs,
disturbing its fast iteration cycle. Disable it by running:

```
sudo spctl developer-mode enable-terminal
```

Then, select terminal program (e.g. kitty.app)
at "Preferences > Security & Privacy > Privacy > Developer Tools".

## 1.1.1.1 as DNS resolver

Set DNS resolver to [`1.1.1.1`](https://1.1.1.1),
a [fast, privacy-focused](https://blog.cloudflare.com/announcing-1111/)
consumer DNS service from Cloudflare,
by going to "System Preferences > Network > Advanced... > DNS",
clicking "+", entering "1.1.1.1", clicking "OK",
and clicking "Apply".
