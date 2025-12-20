#!/bin/bash

PACKAGES=(stow kitty wofi hyprland hypridle hyprlock waybar)
pacman -Syu "${PACKAGES[@]}"

STOWABLES=(kitty hyprland hyprlock waybar)

stow "${STOWABLES[@]}"
