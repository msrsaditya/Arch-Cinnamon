# Use Either Full Link or Shortened Bitly Link
# Pre-Installation

archinstall --config https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/user_configuration.json --creds https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/user_credentials.json
archinstall --config https://bit.ly/4f10PCf --creds https://bit.ly/3D9cxxb

# Post-Installation

wget "https://raw.githubusercontent.com/msrsaditya/Arch-Cinnamon/refs/heads/main/Installation/PostInstall.sh"
wget "https://bit.ly/4f9ENgt"

sudo chmod +x PostInstall.sh
sudo bash PostInstall.sh
