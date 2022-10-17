# Laptop

Dotfiles and an install/update script:

```
export LAPTOP="$HOME/laptop"
git clone https://github.com/croaky/laptop.git $LAPTOP
cd $LAPTOP
./laptop.sh
```

![screenshot](https://user-images.githubusercontent.com/198/116731106-23792180-a99e-11eb-8afc-ecbbcdf58940.png)

## Extras

The following items are not part of the script.
They generally are more "one time setup" items.

### Keyboard

Configure "System Preferences > Keyboard":

* Set "Key Repeat" to "Fast".
* Set "Delay Until Repeat" to "Short".
* Set "Modifier Keys > Caps Lock Key" to "^ Control".

### macOS apps

Install macOS apps:

* [Magnet.app](https://apps.apple.com/us/app/magnet/id441258766?mt=12)
* [Postgres.app](https://postgresapp.com/)

### SSH key

[Create an SSH key](https://dancroak.com/ssh-ed25519):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$(whoami)@$(hostname)"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub | pbcopy
```

[Upload SSH key to GitHub](https://github.com/settings/keys).

### Binary malware scans

A macOS feature that scans new binaries for malware
adds an extra ~2s on to every build of Go programs,
disturbing its fast iteration cycle. Disable it by running:

```
sudo spctl developer-mode enable-terminal
```

Then, select terminal program (e.g. kitty.app)
at Preferences > Security & Privacy > Privacy > Developer Tools.
