#!/bin/bash
set -e

NETPLAN_DIR="/etc/netplan"

# pega o primeiro arquivo .yml ou .yaml
FILE=$(ls $NETPLAN_DIR/*.yml $NETPLAN_DIR/*.yaml 2>/dev/null | head -n 1)

if [ -z "$FILE" ]; then
    echo "[ERRO] Nenhum arquivo .yml ou .yaml encontrado em $NETPLAN_DIR"
    exit 1
fi

# backup
cp "$FILE" "$FILE.dhcp"
echo "[INFO] Backup criado em $FILE.dhcp"

# ALTERE A INTERFACE, IP, GATEWAY E DNS
cat > "$FILE" <<EOF
network:
  version: 2
  ethernets:
    enp0s3:
      # IP
      addresses:
        - 192.168.2.43/24
      # DNS  
      nameservers:
        addresses:
          - 192.168.2.30
          - 8.8.8.8
      # GATEWAY
      routes:
        - to: default
          via: 192.168.2.216

    #enX1:
      #addresses:
        #- 192.168.2.42/24
EOF

echo "[INFO] Arquivo $FILE atualizado. Rode 'netplan apply' manualmente quando quiser ativar."
