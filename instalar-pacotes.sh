#!/bin/bash
set -e

# Lista de pacotes essenciais
PACOTES_ESSENCIAIS=(
    htop iotop nethogs iftop dstat ncdu
    net-tools iputils-ping dnsutils traceroute
    curl wget aria2 ssh openssh-client openssh-server
    software-properties-common apt-transport-https
    ca-certificates gnupg lsb-release ubuntu-restricted-extras
    build-essential
    plocate
    lshw inxi lsof strace hdparm
    python3 python3-pip python3-venv python3-dev
    pipx jq yq tmux screen zip unrar testdisk fdupes
)

echo "[INFO] Atualizando lista de pacotes..."
sudo apt update -y

echo "[INFO] Instalando pacotes essenciais..."
sudo apt install -y "${PACOTES_ESSENCIAIS[@]}"

echo "[INFO] Limpando pacotes desnecessários..."
sudo apt autoremove -y
sudo apt clean

echo "[INFO] Instalação concluída!"
