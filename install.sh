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

include_files(){
     echo -e "\n${blueColour}[+] Including additional configuration files...${endColour}"
    #-------------------------------------------------------------
    mkdir -p "$USER_HOME_DIR/.config/kitty"
    cp "$ruta/kitty/kitty.conf" "$USER_HOME_DIR/.config/kitty/"
    cp "$ruta/kitty/color.ini" "$USER_HOME_DIR/.config/kitty/"
    #-------------------------------------------------------------
    if [[ -f "$ruta/.zshrc" ]]; then
        cp "$ruta/.zshrc" "$USER_HOME_DIR/"
        # Crear enlace simbólico en /root si es diferente al usuario
        if [[ "$USER_HOME_DIR" != "/root" ]]; then
            ln -sf "$USER_HOME_DIR/.zshrc" /root/.zshrc
        fi
    fi
}

move_fonts() {
    echo -e "\n${blueColour}[+] Moving fonts to user fonts directory...${endColour}"
    mkdir -p "$USER_HOME_DIR/Downloads"
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
move_fonts
include_files
zsh_default
p10k_install
fix_permissions

echo -e "\n${greenColour}[✓] All tasks completed successfully!${endColour}\n"
