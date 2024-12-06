#!/bin/bash

## Package Management

# Update Everything and Clean
pacman -Syyu --noconfirm && pacman -Rns --noconfirm $(pacman -Qdtq)

# Pacman Configuration Edit
sed -i '/^#Color/s/^#//' /etc/pacman.conf
sed -i '/^#ParallelDownloads/s/^#//' /etc/pacman.conf
grep -q "^ILoveCandy" /etc/pacman.conf || echo "ILoveCandy" >> /etc/pacman.conf
sed -i 's/^#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/' /etc/makepkg.conf

# Install Necessary Applications from Official Repos
pacman -Syyu --noconfirm alacritty aria2 bleachbit cinnamon curl eog evince fastfetch ffmpeg git gvfs-mtp htop lf libreoffice-fresh lightdm man-db mpv mtpfs networkmanager nemo neovim noto-fonts-emoji openssh otf-font-awesome pandoc-cli p7zip reflector tar touchegg ttf-jetbrains-mono-nerd unrar unzip upower vbetool wget wireless_tools xclip xed xdg-utils xdg-user-dirs yt-dlp zsh zsh-autosuggestions zsh-syntax-highlighting

# Install Yay AUR Helper
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si && cd
rm -rf yay

# Install Necessary Applications from AUR
yay -S --noconfirm brave-bin file-roller-linuxmint gnome-calculator-gtk3 jmtpfs mint-themes mint-y-icons

## Login Behavior

# Turn Off Mitigations and Skip Grub on Login
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ mitigations=off"/' /etc/default/grub
sed -i '/^GRUB_TIMEOUT=/d' /etc/default/grub
echo "GRUB_TIMEOUT=0" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Login to TTY, not GUI by Default
systemctl set-default multi-user.target

# Setup Auto Login in LightDM (if using GUI as default)
sed -i '/^autologin-user=/d; /^autologin-user-timeout=/d; /^autologin-session=/d' /etc/lightdm/lightdm.conf
echo -e "[Seat:*]\nautologin-user=user\nautologin-user-timeout=0\nautologin-session=cinnamon" >> /etc/lightdm/lightdm.conf

echo "auth required pam_succeed_if.so user ingroup nopasswdlogin" >> /etc/pam.d/lightdm

groupadd -r autologin
groupadd -r nopasswdlogin
gpasswd -a user autologin
gpasswd -a user nopasswdlogin

# Remove Chromium Password Prompt on Auto Login
rm ~/.local/share/keyrings/*

# Turn off Suspend on Lid Close
sed -i '/^HandleLidSwitch=/d; /^HandleLidSwitchExternalPower=/d; /^HandleLidSwitchDocked=/d' /etc/systemd/logind.conf
echo -e "HandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore" >> /etc/systemd/logind.conf

systemctl restart systemd-logind.service

# Remove Repeated Authentication Prompting in CLI
echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

## Copy Configs from GitHub

# Create Necessary Folders and Files
xdg-user-dirs-update
mkdir -p ~/.config/alacritty/ ~/.config/aria2/ ~/.config/fastfetch/ ~/.config/lf/ ~/.config/nvim/ ~/.local/share/Trash/files/ ~/Documents/Projects/YT-Digest/

git clone "https://github.com/msrsaditya/Arch-Cinnamon"

cp ~/Arch-Cinnamon/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml \
    ~/Arch-Cinnamon/aria2/aria2.conf ~/.config/aria2/aria2.conf \
    ~/Arch-Cinnamon/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc \
    ~/Arch-Cinnamon/lf/colors ~/.config/lf/colors \
    ~/Arch-Cinnamon/lf/icons ~/.config/lf/icons \
    ~/Arch-Cinnamon/lf/lfrc ~/.config/lf/lfrc \
    ~/Arch-Cinnamon/nvim/init.lua ~/.config/nvim/init.lua \
    ~/Arch-Cinnamon/zsh/zshrc ~/.zshrc \
    ~/Arch-Cinnamon/YT-Digest.sh ~/Documents/Projects/YT-Digest/ \
    ~/Arch-Cinnamon/style.css ~/Documents/Projects/YT-Digest/

touch ~/Documents/Projects/YT-Digest/URL.txt
chmod +x ~/Documents/Projects/YT-Digest/YT-Digest.sh

rm -rf Arch-Cinnamon

# Create a Python Virtual Environment
python -m venv Documents/Projects/.venv
pip install --upgrade pip youtube-transcript-api

# Setup SSH
systemctl enable sshd
ssh-keygen -t ed25519 -C "linux-ssh-key"
ssh-copy-id shashank@192.168.29.9
# ip addr show wlan0
# ssh shashank@192.168.29.9

# Change Shell to ZSH
chsh -s $(which zsh)

# Remove Unnecessary Files
rm -rf ~/.bash_history ~/.bash_logout ~/.bash_profile ~/.bashrc ~/.cache
