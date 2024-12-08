#!/bin/bash

# Remove Repeated Authentication Prompting in CLI
echo "user ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

## Package Management

# Update Everything and Clean
sudo pacman -Syyu --noconfirm && sudo pacman -Rns --noconfirm $(pacman -Qdtq)

# Pacman Configuration Edit
sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf
sudo sed -i 's/^#*ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
sudo sed -i '/ParallelDownloads = 10/a ILoveCandy' /etc/pacman.conf
sudo sed -i 's/^#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/' /etc/makepkg.conf

# Install Necessary Applications from Official Repos
sudo pacman -Syyu --noconfirm alacritty aria2 bleachbit cinnamon curl eog evince fastfetch ffmpeg fzf git gvfs-mtp htop lf libreoffice-fresh lightdm man-db mpv mtpfs networkmanager nemo neovim noto-fonts-emoji openssh otf-font-awesome pandoc-cli p7zip python python-pip reflector tar touchegg ttf-jetbrains-mono-nerd unrar unzip upower vbetool wget wireless_tools xclip xed xdg-utils xdg-user-dirs yt-dlp zsh zsh-autosuggestions zsh-syntax-highlighting

# Install Yay AUR Helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd
rm -rf yay

# Install Necessary Applications from AUR
yay -S --noconfirm brave-bin gnome-calculator-gtk3 jmtpfs mint-y-icons
# file-roller-linuxmint mint-themes

# Update Everything and Clean Again
sudo pacman -Syyu --noconfirm && sudo pacman -Rns --noconfirm $(pacman -Qdtq)

### Login Behavior

## Bootloader

# Turn Off Mitigations and Skip Grub on Login
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ mitigations=off"/' /etc/default/grub
sudo sed -i '/^GRUB_TIMEOUT=/d' /etc/default/grub
echo "GRUB_TIMEOUT=0" | sudo tee -a /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

## TTY

# Login to TTY, not GUI by Default
sudo systemctl set-default multi-user.target

# TTY AutoLogin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null <<EOL
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin user --noclear %I linux
ExecStartPre=-/bin/sh -c "TERM=linux setterm --blank 0 >/dev/tty1"
EOL
sudo systemctl enable getty@tty1.service

## GUI

# Setup Auto Login in LightDM (for using GUI as default)
sudo sed -i '/^autologin-user=/d; /^autologin-user-timeout=/d; /^autologin-session=/d' /etc/lightdm/lightdm.conf
echo -e "[Seat:*]\nautologin-user=user\nautologin-user-timeout=0\nautologin-session=cinnamon" | sudo tee -a /etc/lightdm/lightdm.conf
echo "auth required pam_succeed_if.so user ingroup nopasswdlogin" | sudo tee -a /etc/pam.d/lightdm

sudo groupadd -r autologin
sudo groupadd -r nopasswdlogin
sudo gpasswd -a user autologin
sudo gpasswd -a user nopasswdlogin

# Remove Chromium Password Prompt on Auto Login
rm ~/.local/share/keyrings/*

# Turn off Suspend on Lid Close
sudo sed -i '/^HandleLidSwitch=/d; /^HandleLidSwitchExternalPower=/d; /^HandleLidSwitchDocked=/d' /etc/systemd/logind.conf
echo -e "HandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore" | sudo tee -a /etc/systemd/logind.conf
sudo systemctl restart systemd-logind.service

## Copy Configs from GitHub

git clone "https://github.com/msrsaditya/Arch-Cinnamon"

# Create Necessary Folders and Files First
xdg-user-dirs-update
mkdir -p ~/.config/alacritty/ ~/.config/aria2/ ~/.config/fastfetch/ ~/.config/lf/ ~/.config/nvim/ ~/.local/share/Trash/files/

# Copy
cp ~/Arch-Cinnamon/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
cp ~/Arch-Cinnamon/aria2/aria2.conf ~/.config/aria2/aria2.conf
cp ~/Arch-Cinnamon/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
cp ~/Arch-Cinnamon/lf/colors ~/.config/lf/colors
cp ~/Arch-Cinnamon/lf/icons ~/.config/lf/icons
cp ~/Arch-Cinnamon/lf/lfrc ~/.config/lf/lfrc
cp ~/Arch-Cinnamon/nvim/init.lua ~/.config/nvim/init.lua
cp ~/Arch-Cinnamon/zsh/zshrc ~/.zshrc

# Remove the Cloned Directory
rm -rf Arch-Cinnamon

# Create a Python Virtual Environment
python -m venv ~/Documents/Projects/.venv
source ~/Documents/Projects/.venv/bin/activate
pip install --upgrade pip
deactivate

## Setup SSH
sudo systemctl enable sshd
# ssh-keygen -t ed25519 -C "linux-ssh-key"
# ssh-copy-id shashank@192.168.29.9
# ip addr show wlan0
# ssh shashank@192.168.29.9

# Change Shell to ZSH
sudo chsh -s $(which zsh)

# Remove Unnecessary Files
rm -rf ~/.bash_history ~/.bash_logout ~/.bash_profile ~/.bashrc ~/.cache
