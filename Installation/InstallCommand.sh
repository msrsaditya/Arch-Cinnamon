### Takes Roughly 35 (15+20) Minutes for Complete Installation from Scratch

## Prerequisite Commands for Pre-Installation

# iwctl
# ping archlinux.org
# sudo pacman -Syy archinstall

## How to Fix archinstall not Working

# sudo pacman -Syy archinstall archlinux-keyring python python-pyparted python-simple-term-menu python-annotated-types python-pydantic python-pydantic-core python-typing_extensions

## Use Either Full Link or Shortened Bitly Link

# Pre-Installation (~15 Minutes)

archinstall --config https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PreInstallation/user_configuration.json --creds https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PreInstallation/user_credentials.json
archinstall --config https://bit.ly/4ii7E5n --creds https://bit.ly/4fUn4uO

## Reboot Now

# Post-Installation (~20 Minutes)

wget "https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PostInstallation/PostInstall.sh"
wget --content-disposition "https://bit.ly/3Vqxlqr"

sudo chmod +x PostInstall.sh
bash PostInstall.sh

## Reboot Again
