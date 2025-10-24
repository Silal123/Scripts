#!/bin/bash
# How to user:
# bash <(curl https://raw.githubusercontent.com/Silal123/Scripts/refs/heads/main/installer/docker.sh)

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

progress_bar() {
    local duration=$1
    local interval=0.1
    local total_steps=$(echo "$duration / $interval" | bc)
    for ((i = 0; i<=total_steps; i++)); do
        percent=$((100*i/total_steps))
        bar=$(printf "%-${percent}s" "#" | tr ' ' '#')
        echo -ne "\r[${bar:0:50}] ${percent}"
        sleep $interval
    done
    echo
}

ask() {
    local prompt=$1
    local default=${2:-n}
    local choice

    read -p "$prompt (y/n) [$default]: " choice
    choice=${choice:-$default}

    [[ "$choice" =~ ^[Yy]$ ]]
}

remove_docker=false
add_repository=false
install_docker=false

if ask "Do you want to uninstall docker first?" "n"; then
    remove_docker=true
else
    remove_docker=false
fi

if ask "Do you want to add the Docker Repository?", "y"; then
    add_repository=true
else
    add_repository=false
fi

if ask "Do you want to install Docker?", "y"; then
    install_docker=true
else
    install_docker=false
fi

if ! ask "Do you want to continue with the installation?", "n"; then
    echo -e "${RED}Aborting installation...${RESET}"
    exit 0
fi

if [ "$remove_docker" = true ]; then
    echo -e "${YELLOW}Removing Docker...${RESET}"
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
        sudo apt-get remove -y $pkg;
    done
    echo -e "${GREEN}Removed Docker!${RESET}"
fi

if [ "$add_repository" = true ]; then
    echo -e "${YELLOW}Adding Docker Repository...${RESET}"

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

    echo -e "${GREEN}Added Docker Repository!${RESET}"
fi

if [ "$install_docker" = true ]; then
    echo -e "${YELLOW}Installing Docker...${RESET}"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo -e "${GREEN}Installed Docker!${RESET}"
fi