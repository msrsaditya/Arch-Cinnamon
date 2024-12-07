# Takes Roughly 30 (14+16) Minutes for Complete Installation from Scratch

## Prerequisite Commands for Pre-Installation

# iwctl
# ping archlinux.org
# sudo pacman -Syy archinstall

# Pre-Installation (Use Either Full Link or Shortened Bitly Link)

archinstall --config https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PreInstallation/user_configuration.json --creds https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PreInstallation/user_credentials.json
archinstall --config https://bit.ly/4ii7E5n --creds https://bit.ly/4fUn4uO

# Post-Installation

wget "https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PostInstallation/PostInstall.sh"
wget --content-disposition "https://bit.ly/3Vqxlqr"

sudo chmod +x PostInstall.sh
./PostInstall.sh
