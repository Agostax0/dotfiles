#!/bin/bash

PACKAGES=(stow kitty rofi hyprland hypridle hyprlock hyprpaper waybar otf-font-awesome brave-browser wl-clipboard)
pacman -Syu "${PACKAGES[@]}"

STOWABLES=(kitty hyprland hyprlock waybar hyprpaper wallpapers)

stow "${STOWABLES[@]}"
