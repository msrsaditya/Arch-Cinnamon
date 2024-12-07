# Use Either Full Link or Shortened Bitly Link
# Pre-Installation

archinstall --config https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PreInstallation/user_configuration.json --creds https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PreInstallation/user_credentials.json
archinstall --config https://bit.ly/4ii7E5n --creds https://bit.ly/4fUn4uO

# Post-Installation

wget "https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PostInstallation/PostInstall.sh"
wget "https://bit.ly/3Vqxlqr"

sudo chmod +x PostInstall.sh
sudo bash PostInstall.sh
