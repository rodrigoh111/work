#!/bin/bash
set -e

echo "[+] Parando serviços do Docker..."
sudo systemctl stop docker || true
sudo systemctl stop docker.socket || true

echo "[+] Removendo pacotes Docker e Compose..."
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
sudo apt-get autoremove -y --purge
sudo apt-get autoclean -y

echo "[+] Removendo diretórios e sobras..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /etc/systemd/system/docker.service.d
sudo rm -rf /usr/local/bin/docker-compose
sudo rm -rf /docker

echo "[+] Conferindo se sobrou algo..."
dpkg -l | grep -i docker || echo "Nenhum pacote docker encontrado."

echo "[✓] Docker e Docker Compose removidos."
