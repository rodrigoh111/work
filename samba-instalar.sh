#!/bin/bash

# Script para instalar e configurar samba
# e configurar permissões

set -euo pipefail

# Cores para output
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # No Color

# Verificar root
if [ "$EUID" -ne 0 ]; then
    echo -e "${VERMELHO}Por favor, execute como root usando sudo!${NC}"
    exit 1
fi

# Atualizar lista de pacotes
echo -e "${AZUL}Atualizando lista de pacotes...${NC}"
apt update && apt upgrade -y

echo "Instalando o Samba..."
sudo apt install samba -y

echo ""
echo "Criando backup do arquivo de configuração original..."
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

echo ""
echo "Configurando o smb.conf..."

# Criar o arquivo de configuração do Samba
sudo tee /etc/samba/smb.conf > /dev/null << EOF
[global]
   workgroup = WORKGROUP
   server string = %h server (Samba, Ubuntu)
   server role = standalone server
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = no

[web]
   comment = web
   path = /var/www
   browseable = yes
   create mask = 0777
   directory mask = 0777
   force create mode = 0777
   force directory mode = 0777
   writable = yes
   read only = no
   valid users = web
   #force user = www-data
   #force group = ti

[logs]
   comment = logs
   path = /var/log/life
   browseable = yes
   create mask = 0777
   directory mask = 0777
   force create mode = 0777
   force directory mode = 0777
   writable = yes
   read only = no
   valid users = web
   #force user = www-data
   #force group = ti

[empresas]
   comment = empresas
   path = /var/www/empresas
   browseable = yes
   create mask = 0777
   directory mask = 0777
   force create mode = 0777
   force directory mode = 0777
   writable = yes
   read only = no
   valid users = web
   #force user = www-data
   #force group = ti
EOF

echo ""
echo "Adicionando usuário 'web' ao sistema..."
# Verificar se o usuário já existe, se não, criar
if ! id "web" &>/dev/null; then
    sudo adduser --system --no-create-home --group web
    echo "✓ Usuário 'web' criado"
else
    echo "✓ Usuário 'web' já existe"
fi

echo ""
echo "Configurando senha do Samba para o usuário 'web'..."
echo "Por favor, digite a senha 'SENHA' quando solicitado:"
sudo smbpasswd -a USUARIO1 <<EOF
SENHA
SENHA
EOF

#sudo smbpasswd -a USUARIO2 <<EOF
#SENHA
#SENHA
#EOF

echo ""
echo "Reiniciando o serviço Samba..."
sudo systemctl restart smbd
sudo systemctl enable smbd

echo ""
echo "Verificando status do serviço..."
sudo systemctl status smbd --no-pager -l

echo ""
echo "Verificando configuração do Samba..."
sudo testparm -s

echo ""
echo "Configuração concluída!"
echo ""
echo "Compartilhamentos configurados:"
echo "  - [web]      : /var/www"
echo "  - [logs]     : /var/log/life" 
echo "  - [empresas] : /var/www/empresas"
echo ""
echo "Para acessar de outra máquina Windows:"
echo "\\\\IP_DO_SERVIDOR\\web"
echo "\\\\IP_DO_SERVIDOR\\logs"
echo "\\\\IP_DO_SERVIDOR\\empresas"

echo " "
echo "Remover pacotes e limpar cache"
# Remover pacotes órfãos e limpar cache
echo -e "${AZUL}Limpando pacotes órfãos e cache...${NC}"
apt autoremove --purge -y
apt clean
apt autoclean

echo "(!) Script finalizado - instalado samba
