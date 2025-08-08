#!/usr/bin/env bash

CONFIG_LST=("hypr" "kitty" "swaync" "sys64" "waybar" "wlogout" "wofi" "xdg-desktop-portal" "dolphinrc")
LOCAL_LST=("color-schemes" "themes")

PKGS="hyprland hyprpaper hypridle hyprlock hyprcursor kitty wofi papirus-icon-theme nwg-look"
PKGS+=" mate-polkit xdg-desktop-portal-hyprland xdg-desktop-portal-gtk" #portals & auth
PKGS+=" waybar swaync cliphist network-manager-applet brightnessctl" #bar
PKGS+=" noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-nerd-fonts-symbols" #fonts
PKGS+=" dolphin ark ly" #extra utils
CHAOTIC_AUR_PKGS="wlogout phonon-qt6-mpv darkly-qt6-git bibata-cursor-theme qt6ct-kde" #Avilable on Chotic AUR
# Note: phonon-qt6-mpv is optiona (included to remove vlc)
#       ly is optional (tui display manager)
AUR_PKGS="syshud" #Not Avilable on Chotic AUR
