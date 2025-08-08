#!/bin/env bash

set -e # Exit on any error

CONFIG_DIR="$HOME/.config"
LOCAL_DIR="$HOME/.local/share"

prompt() { echo -ne " \e[92m*\e[39m $*"; }

err() { echo -e " \e[91m*\e[39m $*" && exit 1; }

pr () { echo -e "\e[92m$*\e[39m"; }

copy() {
    local SOURCE_DIR="$2"
    local DEST_DIR="$3"

    [[ "${ESCALATION_TOOL}" = "eval" ]] && err "Copying dots to root. Aborting!"
    if [[ "$1" == "conf" ]]; then
        for DOTS in "${CONFIG_LST[@]}"; do
            rsync -a --info=name1,progress1 "${SOURCE_DIR}/${DOTS}" "${DEST_DIR}"
        done

    elif [[ "$1" == "local" ]]; then
        for DOTS in "${LOCAL_LST[@]}"; do
            rsync -a --info=name1,progress1 "${SOURCE_DIR}/${DOTS}" "${DEST_DIR}"
        done
    fi
    echo "Sync complete!"
}

# kanged from: linutils
# https://github.com/ChrisTitusTech/linutil/blob/main/core/tabs/system-setup/arch/server-setup.sh#L66C1-L118C2
select_option() {
    set +e
    local options=("$@")
    local num_options=${#options[@]}
    local selected=0
    local last_selected=-1

    while true; do
        # Move cursor up to the start of the menu
        if [ $last_selected -ne -1 ]; then
            echo -ne "\033[${num_options}A"
        fi

        if [ $last_selected -eq -1 ]; then
            echo "Please select an option using the arrow keys and Enter:"
        fi
        for i in "${!options[@]}"; do
            if [ "$i" -eq $selected ]; then
                pr "> ${options[$i]}"
            else
                echo "  ${options[$i]}"
            fi
        done

        last_selected=$selected

        # Read user input
        read -rsn1 key
        case $key in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 key
                case $key in
                    '[A') # Up arrow
                        ((selected--))
                        if [ $selected -lt 0 ]; then
                            selected=$((num_options - 1))
                        fi
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        if [ "$selected" -ge "$num_options" ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '') # Enter key
                break
                ;;
        esac
    done

    return $selected
}

enable-chaotic-aur() {
    "$ESCALATION_TOOL" bash <<ROOT
    pacman-key --recv-key "3056513887B78AEB" --keyserver "keyserver.ubuntu.com"
    pacman-key --lsign-key "3056513887B78AEB"

    pacman -U --noconfirm --needed 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    pacman -U --noconfirm --needed 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
ROOT

    if [[ -f  /etc/pacman.d/chaotic-mirrorlist ]] && [[ -f /usr/share/pacman/keyrings/chaotic.gpg ]]; then
        echo -e  "\n[chaotic-aur]" | "$ESCALATION_TOOL" tee -a /etc/pacman.conf
        echo "Include = /etc/pacman.d/chaotic-mirrorlist" | "$ESCALATION_TOOL" tee -a /etc/pacman.conf
        "$ESCALATION_TOOL" pacman -Syy
    fi
}

install-yay() {
    "$ESCALATION_TOOL" pacman -S --needed --noconfirm base-devel git
    mkdir -p "${HOME}/aur" && cd "${HOME}/aur"
    git clone https://aur.archlinux.org/yay-bin.git || err "yay clone failed directory occupied"
    cd yay-bin && makepkg --noconfirm -si
    pr "Yay installed"
}

install-paru() {
    "$ESCALATION_TOOL" pacman -S --needed --noconfirm base-devel git
    mkdir -p "${HOME}/aur" && cd "${HOME}/aur"
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin && makepkg --noconfirm -si
    pr "Paru installed"
}

aur-helper-check() {
    if ! grep -q "^\s*\[chaotic-aur\]" /etc/pacman.conf; then
        for tool in yay paru; do
            command -v "${tool}" >/dev/null 2>&1 && AUR_HELPER=${tool}
        done

        pr "No AUR Helper or Chaotic AUR found!"

        options=("Install & Enable Chaotic Aur" "Install yay" "Install paru" "Exit")
        select_option "${options[@]}"
        local EXIT_STATUS="$?"

        case $EXIT_STATUS in
            0) enable-chaotic-aur;;
            1) install-yay;;
            2) install-paru;;
            3) err "Aborting... ";;
            *) echo "Wrong option please select again"; aur-helper-handler;;
        esac
    else
        grep -q "^\s*\[chaotic-aur\]" /etc/pacman.conf && export CHAOTIC_AUR="true"
    fi
}

# Plasma
plasma() {
    source plasma/dot.sh

    options=("Backup" "Restore" "Exit")
    select_option "${options[@]}"
    local EXIT_STATUS="$?"

    case $EXIT_STATUS in
        0)
            pr "Creating Backup of Plasma Configs."
            copy "conf" "${CONFIG_DIR}" "./plasma/config/"
            copy "local" "${LOCAL_DIR}" "./plasma/local/"
        ;;
        1)
            mkdir -p "$LOCAL_DIR" "$CONFIG_DIR"
            options=("Only Configs" "Packages & Configs" "Exit")
            select_option "${options[@]}"
            local EXIT_STATUS="$?"

            if [[ $EXIT_STATUS == 0 ]]; then
                pr "Restoring Plasma Configs & Local"
                copy "conf" "./plasma/config/" "${CONFIG_DIR}"
                copy "local" "./plasma/local/" "${LOCAL_DIR}"

            elif [[ $EXIT_STATUS == 1 ]]; then
                [[ -z "${DISABLE_PACKAGE}" ]] || err "Package Installation is available only for Arch Linux."
                pr "Packages to be installed:-\n${PKGS}"
                prompt "Continue [Y/n]: "
                read -r INSTALL
                INSTALL=${INSTALL:-y}

                if [[ "$INSTALL" == "y" ]]; then
                    # shellcheck disable=SC2086
                    # Ignore PKGS not being quoted pacman will interpret array as single package and fail
                    "$ESCALATION_TOOL" pacman -S --needed ${PKGS} || err "Installistion interrupted!"
                fi

                pr "Restoring Plasma Configs & Local"
                copy "conf" "./plasma/config/" "${CONFIG_DIR}"
                copy "local" "./plasma/local/" "${LOCAL_DIR}"

            elif [[ $EXIT_STATUS == 2 ]]; then
                err "Aborting..."
            fi
        ;;
        2) err "Aborting... ";;
        *) echo "Wrong option please select again"; plasma;;
    esac
}

# Hyprland
hypr() {
    source hyprland/dot.sh

    options=("Backup" "Restore" "Exit")
    select_option "${options[@]}"
    local EXIT_STATUS="$?"

    case $EXIT_STATUS in
        0)
            pr "Creating Backup of Hyprland Configs & Locals."
            copy "conf" "${CONFIG_DIR}" "./hyprland/config/"
            copy "local" "${LOCAL_DIR}" "./hyprland/local/"
        ;;
        1)
            mkdir -p "$LOCAL_DIR" "$CONFIG_DIR"
            options=("Only Configs" "Packages & Configs" "Exit")
            select_option "${options[@]}"
            local EXIT_STATUS="$?"

            if [[ $EXIT_STATUS == 0 ]]; then
                copy "conf" "./hyprland/config/" "${CONFIG_DIR}"
                copy "local" "./hyprland/local/" "${LOCAL_DIR}"

            elif [[ $EXIT_STATUS == 1 ]]; then
                [[ -z "${DISABLE_PACKAGE}" ]] || err "Package Installation is available only for Arch Linux."
                aur-helper-check

                pr "ARCH Packages to be installed:-\n${PKGS}"
                prompt "Continue [Y/n]: "
                read -r INSTALL
                INSTALL=${INSTALL:-y}

                if [[ "$INSTALL" == "y" ]]; then
                    # shellcheck disable=SC2086
                    "$ESCALATION_TOOL" pacman -S --needed --noconfirm ${PKGS} || err "Installation interrupted!"
                fi

                pr "Chaotic AUR Package to be installed:-\n${CHAOTIC_AUR_PKGS}"
                prompt "Continue [Y/n]: "
                read -r INSTALL
                INSTALL=${INSTALL:-y}

                if [[ "$INSTALL" == "y" ]]; then
                    if [[ "${CHAOTIC_AUR}" == true ]]; then
                        # shellcheck disable=SC2086
                        "$ESCALATION_TOOL" pacman -S --needed --noconfirm ${CHAOTIC_AUR_PKGS} || err "Installation interrupted!"
                        #todo syshud installer i.e aur packages direct installer
                    else
                        # shellcheck disable=SC2086
                        "$ESCALATION_TOOL" "$AUR_HELPER" -S --needed --noconfirm ${CHAOTIC_AUR_PKGS} || err "Installation interrupted!"
                    fi
                fi

                pr "Restoring Plasma Configs & Local"
                copy "conf" "./hyprland/config/" "${CONFIG_DIR}"
                copy "local" "./hyprland/local/" "${LOCAL_DIR}"

            elif [[ $EXIT_STATUS == 2 ]]; then
                err "Aborting..."
            fi
        ;;
        2)
        echo "Aborting... " && exit 0
        ;;
        *) echo "Wrong option please select again"; hypr
    esac
}

extra-utils() {
    source utils/dot.sh

    options=("Backup" "Restore" "Exit")
    select_option "${options[@]}"
    local EXIT_STATUS="$?"


}
command -v rsync &> /dev/null || err "rsync not installed. Abort!"

if [ "$(id -u)" = "0" ]; then
    ESCALATION_TOOL="eval"
    echo "Running as root, no escalation neededl"
else
    for tool in sudo doas; do
        command -v "${tool}" >/dev/null 2>&1 && ESCALATION_TOOL=${tool}
    done
    [[ -n "${ESCALATION_TOOL}" ]] && echo "Using ${ESCALATION_TOOL} for privilege escalation"
fi

command -v pacman >/dev/null 2>&1 || export DISABLE_PACKAGE="true"

case $1 in
    plasma)
        plasma
        ;;
    hyprland)
        hypr
        ;;
esac
