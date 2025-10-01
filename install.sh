#!/bin/bash
set -e

# Install required packages
echo "[*] Installing required packages..."
sudo pacman -S --noconfirm hyprland xorg-xrandr rust firefox gedit fastfetch pacman-contrib hyprshot waybar hyprpaper rofi sddm nwg-look kitty nemo hyprpolkitagent pipewire-pulse git xdg-desktop-portal-hyprland git noto-fonts breeze-gtk

# Clone dotfiles 
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "[*] Cloning dotfiles..."
    git clone https://github.com/0xraincandy/dotfiles.git "$DOTFILES_DIR"
fi

# Create .config if doesnt exist
mkdir -p "$HOME/.config"

# List of config folders to symlink
CONFIGS=("hypr" "kitty" "rofi" "waybar" "neofetch" "fastfetch")

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

# Enable SDDM login manager
echo "[*] Enabling SDDM login manager..."
sudo systemctl enable sddm.service

# Clone and install ame from AUR
echo "[*] Installing ame from AUR..."
git clone https://aur.archlinux.org/ame.git
cd ame
makepkg -si --noconfirm
cd ..
rm -rf ame

# Run ame to install font and neofetch packages
echo "[*] Installing all-the-icons fonts and neofetch..."
ame ins ttf-all-the-icons
ame ins neofetch

# Clone GRUB theme
echo "[*] Installing GRUB theme..."
git clone https://github.com/Hitori-Laura/OsageChan_GRUB_theme.git
sudo cp -r OsageChan_GRUB_theme /usr/share/grub/themes

# Add GRUB theme to /etc/default/grub if not already present
GRUB_CONFIG="/etc/default/grub"
GRUB_THEME_LINE='GRUB_THEME="/usr/share/grub/themes/OsageChan_GRUB_theme/theme.txt"'

if ! grep -Fxq "$GRUB_THEME_LINE" "$GRUB_CONFIG"; then
    echo "[*] Adding GRUB theme line to $GRUB_CONFIG"
    echo "$GRUB_THEME_LINE" | sudo tee -a "$GRUB_CONFIG" > /dev/null
else
    echo "[*] GRUB theme line already exists in $GRUB_CONFIG"
fi

# Regenerate GRUB config
echo "[*] Regenerating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Copy GRUB background from dotfiles
echo "[*] Copying GRUB background..."
sudo cp "$DOTFILES_DIR/background.png" /usr/share/grub/themes/OsageChan_GRUB_theme/

# Copy wallpapers
echo "[*] Copying wallpapers..."
mkdir -p "$HOME/Pictures/Wallpapers"
cp "$DOTFILES_DIR/cirno1.jpg" "$HOME/Pictures/Wallpapers/"
cp "$DOTFILES_DIR/cirno.jpg" "$HOME/Pictures/Wallpapers/"

# Add fastfetch command to .bashrc if not already present
BASHRC="$HOME/.bashrc"
FASTFETCH_CMD='fastfetch --logo /home/rain/.config/fastfetch/images/cirno.png --logo-type kitty-direct'

if ! grep -Fxq "$FASTFETCH_CMD" "$BASHRC"; then
    echo "[*] Adding fastfetch command to $BASHRC"
    echo "$FASTFETCH_CMD" >> "$BASHRC"
else
    echo "[*] fastfetch command already exists in $BASHRC"
fi

# Install SDDM Astronaut theme
echo "[*] Installing SDDM Astronaut theme..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"

echo "[✓] All setup completed successfully!"
