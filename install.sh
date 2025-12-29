#!/bin/bash

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

ruta="$(pwd)"


# Ocultar cursor
tput civis

# Restaurar cursor al salir
trap 'tput cnorm' EXIT
trap 'tput cnorm; exit 1' INT TERM

# Obtener home del usuario real
if [[ -n "$SUDO_USER" ]]; then
    USER_HOME_DIR=$(eval echo "~$SUDO_USER")
else
    USER_HOME_DIR="$HOME"
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

    # Dependencias comunes
    apt-get install -y \
        build-essential kitty git vim meson ninja-build \
        libxcb-util0-dev micro libxcb-ewmh-dev libxcb-randr0-dev \
        libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
        libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev \
        >/dev/null 2>&1

    # Polybar
    apt-get install -y \
        cmake cmake-data pkg-config python3-sphinx \
        libcairo2-dev libxcb1-dev libxcb-composite0-dev \
        python3-xcbgen xcb-proto libxcb-image0-dev \
        libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev \
        libpulse-dev libjsoncpp-dev libmpdclient-dev \
        libuv1-dev libnl-genl-3-dev \
        >/dev/null 2>&1

    # Picom
    apt-get install -y \
        meson libxext-dev libxcb-damage0-dev libxcb-xfixes0-dev \
        libxcb-render-util0-dev jq libxcb-render0-dev libxcb-present-dev \
        libpixman-1-dev libev-dev libdbus-1-dev libconfig-dev \
        libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev \
        libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev \
        libxcb-image0-dev libxcb-composite0-dev \
        >/dev/null 2>&1

    # Paquetes adicionales # 1
    apt-get install -y \
        feh scrot scrub rofi xclip bat locate ranger wmname acpi \
        bspwm sxhkd imagemagick \
        >/dev/null 2>&1

    # Paquetes adicionales # 2
    apt-get install -y \
         meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev \
         libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev \
         libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev \
         libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev \
         uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev \
         >/dev/null 2>&1

    echo -e "${greenColour}[✓] Dependencies installed.${endColour}"
}

say_hello
check_root
install_dependencies

echo -e "\n${greenColour}[✓] All tasks completed successfully!${endColour}\n"
