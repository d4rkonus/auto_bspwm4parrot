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


REAL_USER="${SUDO_USER:-$USER}"
USER_HOME_DIR=$(getent passwd "$REAL_USER" | cut -d: -f6)

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
        zsh build-essential kitty git vim meson ninja-build \
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
    mkdir -p "$USER_HOME_DIR/Downloads"
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

move_fonts(){
    echo -e "\n${blueColour}[+] Moving fonts...${endColour}"
    if [[ -d "$ruta/fonts" ]]; then
        cp -r "$ruta/fonts/"* "/usr/local/share/fonts/"
        fc-cache -fv >/dev/null 2>&1
        echo -e "${greenColour}[✓] Fonts moved.${endColour}"
    else
        echo -e "${yellowColour}[!] Fonts directory not found.${endColour}"
    fi
}

zsh_default(){
    usermod --shell /usr/bin/zsh "$REAL_USER"
    usermod --shell /usr/bin/zsh root
}

fix_permissions(){
    echo -e "\n${blueColour}[+] Fixing file permissions...${endColour}"
    if [[ -n "$SUDO_USER" ]]; then
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME_DIR/.config" 2>/dev/null || true
        chown "$SUDO_USER:$SUDO_USER" "$USER_HOME_DIR/.zshrc" 2>/dev/null || true
        chown "$SUDO_USER:$SUDO_USER" "$USER_HOME_DIR/.p10k.zsh" 2>/dev/null || true
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME_DIR/.powerlevel10k" 2>/dev/null || true
    fi
    echo -e "${greenColour}[✓] Permissions fixed.${endColour}"
}

p10k_install(){
    echo -e "\n${blueColour}[+] Installing Powerlevel10k...${endColour}"
    
    # Install for main user
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$USER_HOME_DIR/.powerlevel10k" >/dev/null 2>&1 || true
    
    # Add powerlevel10k to .zshrc if not already present
    if [[ -f "$USER_HOME_DIR/.zshrc" ]] && ! grep -q "powerlevel10k.zsh-theme" "$USER_HOME_DIR/.zshrc"; then
        echo "source $USER_HOME_DIR/.powerlevel10k/powerlevel10k.zsh-theme" >> "$USER_HOME_DIR/.zshrc"
    fi
    
    # Copy custom p10k configuration if exists
    if [[ -f "$ruta/.p10k.zsh" ]]; then
        cp "$ruta/.p10k.zsh" "$USER_HOME_DIR/"
        # Add source of p10k config if not present
        if [[ -f "$USER_HOME_DIR/.zshrc" ]] && ! grep -q ".p10k.zsh" "$USER_HOME_DIR/.zshrc"; then
            echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$USER_HOME_DIR/.zshrc"
        fi
    fi
    
    # Install for root if different from main user
    if [[ "$USER_HOME_DIR" != "/root" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k >/dev/null 2>&1 || true
        
        # Configure root zsh
        if [[ -f "/root/.zshrc" ]] && ! grep -q "powerlevel10k.zsh-theme" "/root/.zshrc"; then
            echo "source /root/.powerlevel10k/powerlevel10k.zsh-theme" >> /root/.zshrc
        fi
        
        # Copy custom p10k configuration for root
        if [[ -f "$ruta/.p10k.zsh" ]]; then
            cp "$ruta/.p10k.zsh" /root/
            if [[ -f "/root/.zshrc" ]] && ! grep -q ".p10k.zsh" "/root/.zshrc"; then
                echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /root/.zshrc
            fi
        fi
    fi
    
    echo -e "${greenColour}[✓] Powerlevel10k installed.${endColour}"
}


say_hello
check_root
install_dependencies
bspwm_and_sxhkd
polybar_install
picom_install
move_fonts
zsh_default
fix_permissions
p10k_install



echo -e "\n${greenColour}[✓] All tasks completed successfully!${endColour}\n"
