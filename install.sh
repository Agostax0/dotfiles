#!/bin/bash

PACKAGES=(stow kitty wofi hyprland hypridle hyprlock hyprpaper waybar otf-font-awesome brave-browser)
pacman -Syu "${PACKAGES[@]}"

STOWABLES=(kitty hyprland hyprlock waybar hyprpaper wallpapers)

stow "${STOWABLES[@]}"
