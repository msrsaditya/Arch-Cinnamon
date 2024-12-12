#!/bin/bash

# Remove Repeated Authentication Prompting in CLI
echo "user ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

## Package Management

# Update all packages and remove orphaned dependencies
echo "Updating system packages..."
sudo pacman -Syyu --noconfirm && sudo pacman -Rns --noconfirm $(pacman -Qdtq)

# Configure Pacman for better UX
echo "Configuring pacman..."
sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf  # Enable colored output
sudo sed -i 's/^#*ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf  # Enable parallel downloads
sudo sed -i '/ParallelDownloads = 10/a ILoveCandy' /etc/pacman.conf  # Add candy progress bar
sudo sed -i 's/^#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/' /etc/makepkg.conf  # Optimize build flags

# Install core applications from official repositories
echo "Installing core applications..."
sudo pacman -Syyu --noconfirm \
  alacritty aria2 bleachbit cinnamon curl eog evince fastfetch ffmpeg fzf git gvfs-mtp htop lf \
  libreoffice-fresh lightdm man-db mpv mtpfs networkmanager nemo neovim noto-fonts-emoji \
  openssh otf-font-awesome pandoc-cli p7zip python python-pip reflector tar touchegg \
  ttf-jetbrains-mono-nerd unrar unzip upower vbetool wget wireless_tools xclip xed xdg-utils \
  xdg-user-dirs yt-dlp zsh zsh-autosuggestions zsh-syntax-highlighting

# Install Yay AUR Helper
echo "Installing yay AUR helper..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Install additional applications from the AUR
echo "Installing AUR applications..."
yay -S --noconfirm brave-bin gnome-calculator-gtk3 jmtpfs mint-themes mint-y-icons

# Final update and cleanup
echo "Final update and cleanup..."
sudo pacman -Syyu --noconfirm && sudo pacman -Rns --noconfirm $(pacman -Qdtq)

### Login Behavior

## Bootloader

# Configure GRUB to disable mitigations and speed up boot time
echo "Configuring GRUB..."
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ mitigations=off"/' /etc/default/grub
sudo sed -i '/^GRUB_TIMEOUT=/d' /etc/default/grub
echo "GRUB_TIMEOUT=0" | sudo tee -a /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

## TTY

# Set default boot target to TTY (multi-user.target)
echo "Setting default boot target to TTY..."
sudo systemctl set-default multi-user.target

# Enable TTY auto-login
echo "Configuring TTY auto-login..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null <<EOL
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin user --noclear %I linux
ExecStartPre=-/bin/sh -c "TERM=linux setterm --blank 0 >/dev/tty1"
EOL
sudo systemctl enable getty@tty1.service

## GUI

# Configure LightDM for GUI auto-login
echo "Configuring LightDM for auto-login..."
sudo sed -i '/^autologin-user=/d; /^autologin-user-timeout=/d; /^autologin-session=/d' /etc/lightdm/lightdm.conf
echo -e "[Seat:*]\nautologin-user=user\nautologin-user-timeout=0\nautologin-session=cinnamon" | sudo tee -a /etc/lightdm/lightdm.conf
echo "auth required pam_succeed_if.so user ingroup nopasswdlogin" | sudo tee -a /etc/pam.d/lightdm

# Add user to necessary groups for auto-login
echo "Adding user to auto-login groups..."
sudo groupadd -r autologin
sudo groupadd -r nopasswdlogin
sudo gpasswd -a user autologin
sudo gpasswd -a user nopasswdlogin

# Remove keyring files to avoid Chromium password prompts
echo "Removing keyring files..."
rm -f ~/.local/share/keyrings/*

# Prevent suspend behavior on lid close
echo "Configuring lid close behavior..."
sudo sed -i '/^HandleLidSwitch=/d; /^HandleLidSwitchExternalPower=/d; /^HandleLidSwitchDocked=/d' /etc/systemd/logind.conf
echo -e "HandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore" | sudo tee -a /etc/systemd/logind.conf
sudo systemctl restart systemd-logind.service

## Copy Configs from GitHub

echo "Cloning configuration files from GitHub..."
git clone "https://github.com/msrsaditya/Arch-Cinnamon"

# Ensure necessary directories exist
echo "Creating configuration directories..."
xdg-user-dirs-update
mkdir -p ~/.config/alacritty/ ~/.config/aria2/ ~/.config/fastfetch/ ~/.config/lf/ ~/.config/nvim/ ~/.local/share/Trash/files/

# Copy configuration files
echo "Copying configuration files..."
cp ~/Arch-Cinnamon/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
cp ~/Arch-Cinnamon/aria2/aria2.conf ~/.config/aria2/aria2.conf
cp ~/Arch-Cinnamon/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
cp ~/Arch-Cinnamon/lf/colors ~/.config/lf/colors
cp ~/Arch-Cinnamon/lf/icons ~/.config/lf/icons
cp ~/Arch-Cinnamon/lf/lfrc ~/.config/lf/lfrc
cp ~/Arch-Cinnamon/nvim/init.lua ~/.config/nvim/init.lua
cp ~/Arch-Cinnamon/zsh/zshrc ~/.zshrc

# Remove cloned repository
echo "Removing cloned repository..."
rm -rf Arch-Cinnamon

# Create and configure Python virtual environment
echo "Setting up Python virtual environment..."
python -m venv ~/Documents/Projects/.venv
source ~/Documents/Projects/.venv/bin/activate
echo "Upgrading pip..."
pip install --upgrade pip
deactivate

## Setup SSH

# Enable SSH daemon
echo "Enabling SSH daemon..."
sudo systemctl enable sshd

# Change default shell to ZSH
echo "Changing default shell to ZSH..."
chsh -s $(which zsh)

# Cleanup unnecessary files
echo "Cleaning up unnecessary files..."
rm -rf ~/.bash_history ~/.bash_logout ~/.bash_profile ~/.bashrc ~/.cache

# Restart system to apply changes
echo "System will now restart..."