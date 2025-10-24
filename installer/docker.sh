#!/bin/bash
# How to user:
# bash <(curl https://raw.githubusercontent.com/Silal123/Scripts/refs/heads/main/installer/docker.sh)

GRAY="\033[1;30m"
WHITE="\033[1;37m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}"
cat << "EOF"
 ____   ___   ____ _  _______ ____  
|  _ \ / _ \ / ___| |/ / ____|  _ \ 
| | | | | | | |   | ' /|  _| | |_) |
| |_| | |_| | |___| . \| |___|  _ < 
|____/ \___/ \____|_|\_\_____|_| \_\
Installer - Created by github.com/Silal123
EOF

echo -e "${RESET}"
echo -e "${GREEN}Welcome to Docker installer!${RESET}"

ask() {
    local prompt=$1
    local default=${2:-n}
    local choice

    read -p "$prompt (y/n) [$default]: " choice
    choice=${choice:-$default}

    log INPUT "$choice"

    [[ "$choice" =~ ^[Yy]$ ]]
}

log() {
    local type=$1
    local message=$2
    local space=$3
    space=${space:-false}

    [ "$space" = true ] && echo ""

    case "$type" in
        SUCCESS) echo -e "${GRAY}[${GREEN}SUCCESS${GRAY}] ${WHITE}$message${RESET}" ;;
        ERROR) echo -e "${GRAY}[${RED}ERROR${GRAY}] ${WHITE}$message${RESET}" ;;
        INFO) echo -e "${GRAY}[${YELLOW}INFO${GRAY}] ${WHITE}$message${RESET}" ;;
        INPUT) echo -e "${GREEN}$message${RESET}" ;;
        *) echo -e "${GRAY}[${CYAN}$type${GRAY}] ${WHITE}$message${RESET}" ;;
    esac

    [ "$space" = true ] && echo ""
}

REMOVE_DOCKER=false
ADD_REPO=true
INSTALL_DOCKER=true

SKIP_ASK=false
if [ $# -gt 0 ]; then
    SKIP_ASK=true
fi

for arg in "$@"; do
    case $arg in
        skip) ;;
        *=*)
            key=${arg%%=*}
            value=${arg%%*=}
            case "$key" in
                remove) REMOVE_DOCKER="$value" ;;
                repo) ADD_REPO="$value" ;;
                install) INSTALL_DOCKER="$value" ;;
                *) echo "Unknown option $arg" ;;
            esac
            ;;
        *) echo "Unknown option $arg" ;;
    esac
done

if [ "$SKIP_ASK" = false ]; then
    if ask "Do you want to uninstall docker first?" "n"; then
        REMOVE_DOCKER=true
    else
        REMOVE_DOCKER=false
    fi

    if ask "Do you want to add the Docker Repository?", "y"; then
        ADD_REPO=true
    else
        ADD_REPO=false
    fi

    if ask "Do you want to install Docker?", "y"; then
        INSTALL_DOCKER=true
    else
        INSTALL_DOCKER=false
    fi

    if ! ask "Do you want to continue with the installation?", "n"; then
        log ERROR "Aborting installation! (Canceled)" false
        exit 0
    fi
fi

if [ "$REMOVE_DOCKER" = true ]; then
    log INFO "Removing Docker..." true
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
        sudo apt-get remove -y $pkg;
    done
    log SUCCESS "Removed Docker!" true
fi

if [ "$ADD_REPO" = true ]; then
    log INFO "Adding Docker Repository..." true

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    log SUCCESS "Added Docker Repository!" true
fi

if [ "$INSTALL_DOCKER" = true ]; then
    log INFO "Installing Docker..." true
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    log SUCCESS "Installed Docker!" true
fi

log SUCCESS "Docker installation script was success!" true