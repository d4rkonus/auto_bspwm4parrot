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
ruta="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

bspwm_and_sxhkd() {
    echo -e "\n${blueColour}[+] Installing bspwm and sxhkd...${endColour}"
    mkdir -p "$USER_HOME_DIR/Downloads"
    cd "$USER_HOME_DIR/Downloads" || exit 1

    [[ -d bspwm ]] || git clone https://github.com/baskerville/bspwm.git >/dev/null 2>&1
    [[ -d sxhkd ]] || git clone https://github.com/baskerville/sxhkd.git >/dev/null 2>&1

    cd bspwm || exit 1
    make >/dev/null 2>&1 || exit 1
    make install >/dev/null 2>&1 || exit 1

    cd ../sxhkd || exit 1
    make >/dev/null 2>&1 || exit 1
    make install >/dev/null 2>&1 || exit 1

    mkdir -p "$USER_HOME_DIR/.config/bspwm" "$USER_HOME_DIR/.config/sxhkd"

    cd ../bspwm/examples || exit 1
    cp bspwmrc "$USER_HOME_DIR/.config/bspwm/"
    chmod +x "$USER_HOME_DIR/.config/bspwm/bspwmrc"

    cp sxhkdrc "$USER_HOME_DIR/.config/sxhkd/"
    cp "$ruta/config/sxhkdrc" "$USER_HOME_DIR/.config/sxhkd/"
    chmod +x "$USER_HOME_DIR/.config/sxhkd/sxhkdrc"
}

polybar_install(){
    echo -e "\n${blueColour}[+] Installing Polybar...${endColour}"
    cd "$USER_HOME_DIR/Downloads" || exit 1

    [[ -d polybar ]] || git clone --recursive https://github.com/polybar/polybar >/dev/null 2>&1
    cd polybar || exit 1
    mkdir -p build && cd build || exit 1

    cmake .. >/dev/null 2>&1 || exit 1
    make -j"$(nproc)" >/dev/null 2>&1 || exit 1
    make install >/dev/null 2>&1 || exit 1

    cd "$USER_HOME_DIR/Downloads" || exit 1
    [[ -d blue-sky ]] || git clone https://github.com/VaughnValle/blue-sky.git >/dev/null 2>&1

    mkdir -p "$USER_HOME_DIR/.config/polybar"
    cp -r blue-sky/polybar/* "$USER_HOME_DIR/.config/polybar/"

    cp "$USER_HOME_DIR/Downloads/blue-sky/polybar/fonts/"*.ttf /usr/share/fonts/truetype/ 2>/dev/null
    fc-cache -v >/dev/null 2>&1

    echo -e "${greenColour}[✓] Polybar installed.${endColour}"
}

picom_install(){
    echo -e "\n${blueColour}[+] Installing Picom...${endColour}"
    cd "$USER_HOME_DIR/Downloads" || exit 1

    [[ -d picom ]] || git clone https://github.com/ibhagwan/picom.git >/dev/null 2>&1
    cd picom || exit 1

    git submodule update --init --recursive >/dev/null 2>&1
    meson --buildtype=release . build >/dev/null 2>&1
    ninja -C build >/dev/null 2>&1
    ninja -C build install >/dev/null 2>&1

    mkdir -p "$USER_HOME_DIR/.config/picom"
    cp "$ruta/config/picom.conf" "$USER_HOME_DIR/.config/picom/"
}

move_fonts(){
    echo -e "\n${blueColour}[+] Moving fonts...${endColour}"
    if [[ -d "$ruta/fonts" ]]; then
        cp "$ruta/fonts/"*.ttf /usr/local/share/fonts/ 2>/dev/null
        fc-cache -fv >/dev/null 2>&1
        echo -e "${greenColour}[✓] Fonts moved.${endColour}"
    else
        echo -e "${yellowColour}[!] Fonts directory not found.${endColour}"
    fi
}

zsh_default(){
    echo -e "\n${blueColour}[+] Configuring Zsh as default shell...${endColour}"

    local ZSH_PATH
    ZSH_PATH="$(command -v zsh)"

    if [[ -z "$ZSH_PATH" ]]; then
        echo -e "${redColour}[!] Zsh not found, skipping shell change.${endColour}"
        return
    fi

    # Usuario real
    if [[ "$(getent passwd "$REAL_USER" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
        usermod --shell "$ZSH_PATH" "$REAL_USER"
        echo -e "${greenColour}[✓] Zsh set for user ${REAL_USER}.${endColour}"
    else
        echo -e "${yellowColour}[!] User ${REAL_USER} already uses Zsh.${endColour}"
    fi

    # Root
    if [[ "$(getent passwd root | cut -d: -f7)" != "$ZSH_PATH" ]]; then
        usermod --shell "$ZSH_PATH" root
        echo -e "${greenColour}[✓] Zsh set for root.${endColour}"
    else
        echo -e "${yellowColour}[!] Root already uses Zsh.${endColour}"
    fi
}

fix_permissions(){
    echo -e "\n${blueColour}[+] Fixing file permissions...${endColour}"
    chown -R "$REAL_USER:$REAL_USER" "$USER_HOME_DIR" 2>/dev/null
    echo -e "${greenColour}[✓] Permissions fixed.${endColour}"
}

p10k_install(){
    echo -e "\n${blueColour}[+] Installing Powerlevel10k...${endColour}"

    local ZSHRC="$USER_HOME_DIR/.zshrc"

    # Clonar Powerlevel10k
    if [[ ! -d "$USER_HOME_DIR/.powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$USER_HOME_DIR/.powerlevel10k" >/dev/null 2>&1
    fi

    # Crear .zshrc si no existe
    [[ -f "$ZSHRC" ]] || touch "$ZSHRC"

    # Cargar Powerlevel10k al inicio del .zshrc
    if ! grep -q "powerlevel10k.zsh-theme" "$ZSHRC"; then
        sed -i '1i source ~/.powerlevel10k/powerlevel10k.zsh-theme' "$ZSHRC"
    fi

    # Copiar configuración p10k
    if [[ -f "$ruta/.p10k.zsh" ]]; then
        cp "$ruta/.p10k.zsh" "$USER_HOME_DIR/"

        if ! grep -q ".p10k.zsh" "$ZSHRC"; then
            echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >> "$ZSHRC"
        fi
    fi

    echo -e "${greenColour}[✓] Powerlevel10k installed.${endColour}"
}

say_hello
check_root
install_dependencies
move_fonts
zsh_default
p10k_install

echo -e "\n${greenColour}[✓] All tasks completed successfully!${endColour}\n"
