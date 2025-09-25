#!/bin/bash
set -e

echo "[INFO] Parando serviços do Samba..."
systemctl stop smbd nmbd winbind 2>/dev/null || true
systemctl disable smbd nmbd winbind 2>/dev/null || true
systemctl mask smbd nmbd winbind 2>/dev/null || true

echo "[INFO] Removendo pacotes Samba..."
apt purge -y samba samba-common samba-common-bin smbclient winbind libwbclient0

echo "[INFO] Limpando dependências não utilizadas..."
apt autoremove -y
apt clean

echo "[INFO] Removendo arquivos de configuração..."
rm -rf /etc/samba
rm -rf /var/lib/samba
rm -rf /var/cache/samba
rm -rf /var/log/samba

echo "[INFO] Samba completamente removido."
