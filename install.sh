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

if [[ -n "$SUDO_USER" ]]; then
    USER_HOME_DIR=$(getent passwd "$SUDO_USER" | cut -d: -f6)
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

bspwm_and_sxhkd() {
    echo -e "\n${blueColour}[+] Cloning bspwm and sxhkd repositories...${endColour}"
    cd "$USER_HOME_DIR/Downloads" || exit 1

    git clone https://github.com/baskerville/bspwm.git >/dev/null 2>&1 || true
    git clone https://github.com/baskerville/sxhkd.git >/dev/null 2>&1 || true

    cd bspwm/ || exit 1
    make >/dev/null 2>&1 || { echo -e "${redColour}[!] Error compiling bspwm${endColour}"; exit 1; }
    make install >/dev/null 2>&1 || { echo -e "${redColour}[!] Error installing bspwm${endColour}"; exit 1; }

    cd ../sxhkd/ || exit 1
    make >/dev/null 2>&1 || { echo -e "${redColour}[!] Error compiling sxhkd${endColour}"; exit 1; }
    make install >/dev/null 2>&1 || { echo -e "${redColour}[!] Error installing sxhkd${endColour}"; exit 1; }

    # Crear configuraciones en el home del usuario
    mkdir -p "$USER_HOME_DIR/.config/bspwm"
    mkdir -p "$USER_HOME_DIR/.config/sxhkd"

    cd ../bspwm/examples || exit 1
    cp bspwmrc "$USER_HOME_DIR/.config/bspwm/" || { echo -e "${redColour}[!] Error copying bspwmrc${endColour}"; exit 1; }
    chmod +x "$USER_HOME_DIR/.config/bspwm/bspwmrc"
    cp sxhkdrc "$USER_HOME_DIR/.config/sxhkd/" || { echo -e "${redColour}[!] Error copying sxhkdrc${endColour}"; exit 1; }
    cp "$ruta/config/sxhkdrc" "$USER_HOME_DIR/.config/sxhkd/" || { echo -e "${redColour}[!] Error copying custom sxhkdrc${endColour}"; exit 1; }
    chmod +x "$USER_HOME_DIR/.config/sxhkd/sxhkdrc"

}

polybar_install(){
    echo -e "\n${blueColour}[+] Installing Polybar...${endColour}"
    cd "$USER_HOME_DIR/Downloads" || exit 1
    git clone --recursive https://github.com/polybar/polybar >/dev/null 2>&1
    cd polybar/ || exit 1
    mkdir build && cd build || exit 1
    cmake .. >/dev/null 2>&1
    make -j$(nproc) >/dev/null 2>&1
    make install >/dev/null 2>&1
    cd "$USER_HOME_DIR/Downloads" || exit 1
    git clone https://github.com/VaughnValle/blue-sky.git >/dev/null 2>&1
    mkdir -p "$USER_HOME_DIR/.config/polybar"
    cp -r blue-sky/polybar/* "$USER_HOME_DIR/.config/polybar/"
    cd "$USER_HOME_DIR/Downloads/blue-sky/polybar/fonts" || exit 1
    cp * /usr/share/fonts/truetype/ >/dev/null 2>&1
    fc-cache -v >/dev/null 2>&1

    echo -e "${greenColour}[✓] Polybar installed.${endColour}"
}

picom_install(){
    echo -e "\n${blueColour}[+] Installing Picom...${endColour}"
    cd "$USER_HOME_DIR/Downloads" || exit 1
    git clone https://github.com/ibhagwan/picom.git >/dev/null 2>&1 || true
    cd picom/ || exit 1
    git submodule update --init --recursive >/dev/null 2>&1
    meson --buildtype=release . build >/dev/null 2>&1
    ninja -C build >/dev/null 2>&1
    ninja -C build install >/dev/null 2>&1
    mkdir -p "$USER_HOME_DIR/.config/picom"
    cp "$ruta/config/picom.conf" "$USER_HOME_DIR/.config/picom/"
    echo -e "${greenColour}[✓] Picom installed.${endColour}"

}



say_hello
check_root
install_dependencies
bspwm_and_sxhkd
polybar_install
picom_install


echo -e "\n${greenColour}[✓] All tasks completed successfully!${endColour}\n"
