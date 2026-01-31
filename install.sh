#!/bin/bash

PACKAGES=(stow kitty hyprland hypridle hyprlock hyprpaper hyprsunset hyprpicker rofi waybar dunst brightnessctl otf-font-awesome brave-browser wl-clipboard hyprshot zsh)
NEEDED_DIRS=(kitty rofi hypr waybar dunst wallpapers)
STOWABLES=(kitty rofi hyprland hypridle hyprlock hyprpaper waybar hyprshot dunst scripts)

echo "Installing packages"
pacman -Sy "${PACKAGES[@]}" --needed --noconfirm

CONFIG_DIR="$HOME/.config/"

echo "Creating folder in .config"
for FOLDER in "${NEEDED_DIRS[@]}"; do
  mkdir -p "$CONFIG_DIR/$FOLDER"
done

echo "Copying zsh configs"
echo ./.zshrc >$HOME/.zshrc
echo "Stowing configs"
stow -t $HOME "${STOWABLES[@]}"

echo "Enabling scripts"
find ./scripts/ -type f -name "*.sh" -exec chmod +x {} \;

echo "Installing mocha theme"
BASE_FONT=monospace
sh -c "cd fonts/ && stow -t $HOME $BASE_FONT"

BASE_WALLPAPER=dragon-of-dojima-dark
sh -c "cd wallpapers/ && stow -t $HOME $BASE_WALLPAPER"

BASE_THEME=mocha
sh -c "cd themes/ && stow -t $HOME $BASE_THEME"
