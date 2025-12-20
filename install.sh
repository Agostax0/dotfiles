#!/bin/bash

PACKAGES=(stow hyprland hypridle hyprlock waybar)
pacman -Syu "${PACKAGES[@]}"

STOWABLES=(hyprland hyprlock waybar)

stow "${STOWABLES[@]}"
