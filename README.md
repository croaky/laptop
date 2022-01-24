# Laptop

Dotfiles and an install/update script:

```
export LAPTOP="$HOME/laptop"
git clone https://github.com/croaky/laptop.git $LAPTOP
cd $LAPTOP
./laptop.sh
```

![screenshot](https://user-images.githubusercontent.com/198/116731106-23792180-a99e-11eb-8afc-ecbbcdf58940.png)

## Out of scope of script

Manually, install macOS apps:

* [Magnet.app](https://apps.apple.com/us/app/magnet/id441258766?mt=12)
* [Postgres.app](https://postgresapp.com/)

[Create an SSH key](https://dancroak.com/ssh-ed25519):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$(whoami)@$(hostname)"
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/id_ed25519
```
