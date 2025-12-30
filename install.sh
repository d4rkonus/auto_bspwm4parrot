#!/bin/bash

# Colours
greenColour="\e[1;32m"
endColour="\e[0m"
redColour="\e[1;31m"
blueColour="\e[1;34m"
yellowColour="\e[1;33m"
purpleColour="\e[1;35m"
turquoiseColour="\e[1;36m"
grayColour="\e[1;37m"

# Ruta real del script (FIX CRÍTICO)
ruta="$(pwd)"

# Ocultar cursor
tput civis 2>/dev/null

# Restaurar cursor al salir
trap 'tput cnorm 2>/dev/null' EXIT
trap 'tput cnorm 2>/dev/null; exit 1' INT TERM

# Usuario real y HOME real (Parrot-safe)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME_DIR=$(getent passwd "$REAL_USER" | cut -d: -f6)

if [[ -z "$USER_HOME_DIR" || ! -d "$USER_HOME_DIR" ]]; then
    echo -e "${redColour}[!] Could not determine real user home directory${endColour}"
    exit 1
fi

say_hello(){
    clear
    echo -e "\n${greenColour}=======================================${endColour}"
    echo -e "${greenColour}        Auto BSPWM Setup Script       ${endColour}"
    echo -e "${greenColour}              by d4rkonus             ${endColour}"
    echo -e "${greenColour}=======================================${endColour}"
}

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo -e "\n${redColour}[!] Please run this script as root.${endColour}"
        exit 1
    fi
}

install_dependencies() {
    echo -e "\n${blueColour}[+] Installing dependencies...${endColour}"
    apt-get update -y >/dev/null 2>&1

    apt-get install -y \
        zsh build-essential kitty git vim meson ninja-build micro \
        libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
        libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
        libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev \
        cmake cmake-data pkg-config python3-sphinx \
        libcairo2-dev libxcb1-dev libxcb-composite0-dev \
        python3-xcbgen xcb-proto libxcb-image0-dev \
        libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev \
        libpulse-dev libjsoncpp-dev libmpdclient-dev \
        libuv1-dev libnl-genl-3-dev \
        libxext-dev libxcb-damage0-dev libxcb-xfixes0-dev \
        libxcb-render-util0-dev jq libxcb-render0-dev libxcb-present-dev \
        libpixman-1-dev libev-dev libdbus-1-dev libconfig-dev \
        libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev \
        libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev \
        feh scrot scrub rofi xclip bat locate ranger wmname acpi imagemagick \
        >/dev/null 2>&1

    echo -e "${greenColour}[✓] Dependencies installed.${endColour}"

}

move_fonts() {
    echo -e "\n${blueColour}[+] Moving fonts to user fonts directory...${endColour}"
    FONT_DIR="$USER_HOME_DIR/usr/share/fonts"
    mkdir -p "$FONT_DIR"

    cp -r "$ruta/fonts/"* "$FONT_DIR/"

    echo -e "${greenColour}[✓] Fonts moved successfully.${endColour}"
}

zsh_default(){
    echo -e "\n${blueColour}[+] Setting Zsh as default shell for user...${endColour}"
    chsh -s /bin/zsh "$REAL_USER"
    echo -e "\n${blueColour}[+] Setting Zsh as default shell for root...${endColour}"
    chsh -s /bin/zsh root
    echo -e "${greenColour}[✓] Zsh set as default shell.${endColour}"
}

say_hello
check_root
install_dependencies
move_fonts
zsh_default


echo -e "\n${greenColour}[✓] All tasks completed successfully!${endColour}\n"
