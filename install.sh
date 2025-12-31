#!/bin/bash

PACKAGES=(stow kitty hyprland hypridle hyprlock hyprpaper hyprsunset hyprpicker rofi waybar dunst brightnessctl otf-font-awesome brave-browser wl-clipboard hyprshot)
NEEDED_DIRS=(kitty rofi hypr waybar dunst)
STOWABLES=(kitty rofi hyprland hypridle hyprlock hyprpaper waybar hyprshot dunst)

echo "Installing packages"
pacman -Sy "${PACKAGES[@]}" --needed --noconfirm

CONFIG_DIR="$HOME/.config/"

echo "Creating folder in .config"
for FOLDER in "${NEEDED_DIRS[@]}"; do
  mkdir -p "$CONFIG_DIR/$FOLDER"
done

echo "Stowing configs"
stow -t ~/ "${STOWABLES[@]}"

echo "Installing mocha theme"
BASE_FONT=monospace
sh -c "cd fonts/ && stow -t ~/ $BASE_FONT"

BASE_WALLPAPER=dragon-of-dojima-dark
sh -c "cd wallpapers/ && stow -t ~/ $BASE_WALLPAPER"

BASE_THEME=mocha
sh -c "cd themes/ && stow -t ~/ $BASE_THEME"
