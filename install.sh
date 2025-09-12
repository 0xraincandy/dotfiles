#!/bin/bash
set -e

# Install required packages
echo "[*] Installing required packages..."
sudo pacman -S --noconfirm hyprland hyprshot waybar hyprpaper rofi sddm breeze-gtk ttf-roboto ttf-ubuntu-font-family ttf-fira-code ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji fontconfig noto-fonts-cjk noto-fonts-emoji noto-fonts nwg-look

# Clone dotfiles if not already cloned
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "[*] Cloning dotfiles..."
    git clone https://github.com/0xraincandy/dotfiles.git "$DOTFILES_DIR"
fi

# Create .config if it doesn't exist
mkdir -p "$HOME/.config"

# List of config folders to symlink
CONFIGS=("hypr" "kitty" "rofi" "waybar")

for config in "${CONFIGS[@]}"; do
    src="$DOTFILES_DIR/$config"
    dest="$HOME/.config/$config"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "[*] Removing existing $dest"
        rm -rf "$dest"
    fi

    echo "[*] Linking $src to $dest"
    ln -s "$src" "$dest"
done

# Optional: enable sddm
echo "[*] Enabling SDDM login manager..."
sudo systemctl enable sddm.service

echo "[✓] Dotfiles installed and configured!"
