#!/bin/bash

PACKAGES=(stow kitty hyprland hypridle hyprlock hyprpaper hyprsunset hyprpicker rofi waybar brightnessctl otf-font-awesome brave-browser wl-clipboard)
pacman -Syu "${PACKAGES[@]}"

STOWABLES=(kitty rofi hyprland hypridle hyprlock hyprpaper waybar)
stow -t ~/ "${STOWABLES[@]}"

BASE_FONT=monospace
sh -c "cd fonts/ && stow -t ~/ $BASE_FONT"

BASE_WALLPAPER=dragon-of-dojima-dark
sh -c "cd wallpapers/ && stow -t ~/ $BASE_WALLPAPER"

BASE_THEME=mocha
sh -c "cd themes/ && stow -t ~/ $BASE_THEME"
