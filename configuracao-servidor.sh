#!/bin/bash

# Script para criar todas as pastas do /var/log/life
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

sudo timedatectl set-timezone America/Sao_Paulo

# Atualizar lista de pacotes
echo -e "${AZUL}Atualizando lista de pacotes...${NC}"
apt update && apt upgrade -y

# Diretório base
BASE_DIR="/var/log/life"

# Array com todas as pastas a serem criadas
PASTAS=(
    "/var/log/life/_LIFEWEB"
    "/var/log/life/_LIFEWEB/_ABASTECIMENTO"
    "/var/log/life/_LIFEWEB/_ABASTECIMENTO/_ARQUIVOS"
    "/var/log/life/_LIFEWEB/_ABASTECIMENTO/_IMPORTACAO"
    "/var/log/life/_LIFEWEB/_ABASTECIMENTO/_ERRO"
    "/var/log/life/_LIFEWEB/_ACESSO"
    "/var/log/life/_LIFEWEB/_FICHAS"
    "/var/log/life/_LIFEWEB/_FICHAS/_FLUXO"
    "/var/log/life/_LIFEWEB/_FICHAS/_TRACE"
    "/var/log/life/_LIFEWEB/_API"
    "/var/log/life/_LIFEWEB/_WS"
    "/var/log/life/_LIFEWEB/_SISTEMAS_HELP"
    "/var/log/life/_LIFEWEB/_SISTEMAS_HELP/_ERRO"
    "/var/log/life/_LIFEWEB/_CONSULTAS"
    "/var/log/life/_LIFEWEB/_LOGIN"
    "/var/log/life/_LIFEWEB/_JORNADA"
    "/var/log/life/_LIFEWEB/_ERRO"
    "/var/log/life/_LIFEWEB/_SAC_ANTT"
    "/var/log/life/_LIFEWEB/_SAC_ANTT/_ARQUIVOS"
    "/var/log/life/_LIFEWEB/_SAC_ANTT/_ERRO"
    "/var/log/life/_API"
    "/var/log/life/_API/_RAST_ONLINE_1"
    "/var/log/life/_API/_RAST_ONLINE_1/_ERRO"
    "/var/log/life/_API/_RAST_HISTORICO"
    "/var/log/life/_API/_RAST_HISTORICO/_ERRO"
    "/var/log/life/_API/_RAST_ONLINE_2"
    "/var/log/life/_API/_RAST_ONLINE_2/_ERRO"
    "/var/log/life/_API/_ERRO"
    "/var/log/life/_WS"
    "/var/log/life/_WS/_LIFEWEB_API"
    "/var/log/life/_WS/_LIFEWEB_API/_ALTERAR_SENHA"
    "/var/log/life/_WS/_LIFEWEB_API/_ALTERAR_SENHA/_ERRO"
    "/var/log/life/_WS/_PCMOV"
    "/var/log/life/_WS/_PCMOV/_BSUL"
    "/var/log/life/_WS/_PCMOV/_BSUL/_ERRO"
    "/var/log/life/_WS/_PCMOV/_MPLAN"
    "/var/log/life/_WS/_PCMOV/_MPLAN/_ERRO"
    "/var/log/life/_WS/_PARAMETROONLINE"
    "/var/log/life/_WS/_MONITRIIP"
    "/var/log/life/_WS/_MONITRIIP/_INTEGRACAO_PRAXIO"
    "/var/log/life/_WS/_MONITRIIP/_NNEMBARCADOS"
    "/var/log/life/_WS/_MONITRIIP/_OCORRENCIA_ROD"
    "/var/log/life/_WS/_MONITRIIP/_OCORRENCIA_ROD/SQLS"
    "/var/log/life/_WS/_MONITRIIP/_OCORRENCIA_ROD/LOGS"
    "/var/log/life/_WS/_MONITRIIP/_OCORRENCIA_ROD/_ERRO"
    "/var/log/life/_WS/_MOOVIT"
    "/var/log/life/_WS/_MOOVIT/_ERRO"
    "/var/log/life/_WS/_RELATORIOAUTOMATICO"
    "/var/log/life/_WS/_RELATORIOAUTOMATICO/_ERRO"
    "/var/log/life/_WS/_PCMOVINFOJSON"
    "/var/log/life/_WS/_PCMOVINFOJSON/_MPLAN"
    "/var/log/life/_WS/_PCMOVINFOJSON/_MPLAN/_ERRO"
    "/var/log/life/_WS/_LIFEAPPCOLETAGERAR"
    "/var/log/life/_WS/_ATENDIMENTOHORARIO"
    "/var/log/life/_WS/_ATENDIMENTOHORARIO/FLUXO"
    "/var/log/life/_WS/_RAST_ONLINE"
    "/var/log/life/_WS/_RAST_ONLINE/_ERRO"
    "/var/log/life/_WS/_NOTIFICACAO_VEIC"
    "/var/log/life/_WS/_NOTIFICACAO_VEIC/_ERRO"
    "/var/log/life/_WS/_VPOS"
    "/var/log/life/_WS/_VPOS/_MOOVIT"
    "/var/log/life/_WS/_VPOS/_MOOVIT/_ERRO"
    "/var/log/life/_WS/_VPOS/_RO"
    "/var/log/life/_WS/_VPOS/_RO/_ERRO"
    "/var/log/life/_WS/_VPOS/_TISAAK"
    "/var/log/life/_WS/_VPOS/_TISAAK/_ERRO"
    "/var/log/life/_WS/_VPOS/_MOBILEBUS"
    "/var/log/life/_WS/_VPOS/_MOBILEBUS/_ERRO"
    "/var/log/life/_WS/_LIFE_CLIENT"
    "/var/log/life/_WS/_LIFE_CLIENT/_FILE_LOG"
    "/var/log/life/_WS/_LIFE_CLIENT/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO"
    "/var/log/life/_WS/_PASSAGEIRO/_LOG"
    "/var/log/life/_WS/_PASSAGEIRO/_CONF"
    "/var/log/life/_WS/_PASSAGEIRO/_CONF/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_ESC_SEMAUT"
    "/var/log/life/_WS/_PASSAGEIRO/_ESC_SEMAUT/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_TRAJETO"
    "/var/log/life/_WS/_PASSAGEIRO/_TRAJETO/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_VEIC_SEMAUT"
    "/var/log/life/_WS/_PASSAGEIRO/_VEIC_SEMAUT/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_ESCPC_SEMAUT"
    "/var/log/life/_WS/_PASSAGEIRO/_ESCPC_SEMAUT/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_ST"
    "/var/log/life/_WS/_PASSAGEIRO/_ST/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_AUT"
    "/var/log/life/_WS/_PASSAGEIRO/_AUT/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_ESC"
    "/var/log/life/_WS/_PASSAGEIRO/_ESC/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_VEIC"
    "/var/log/life/_WS/_PASSAGEIRO/_VEIC/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_ST_SEMAUT"
    "/var/log/life/_WS/_PASSAGEIRO/_ST_SEMAUT/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_TRAJETO_SEMAUT"
    "/var/log/life/_WS/_PASSAGEIRO/_TRAJETO_SEMAUT/_ERRO"
    "/var/log/life/_WS/_PASSAGEIRO/_ESCPC"
    "/var/log/life/_WS/_PASSAGEIRO/_ESCPC/_ERRO"
    "/var/log/life/_WS/_ODOMETRO"
    "/var/log/life/_WS/_ODOMETRO/_ERRO"
    "/var/log/life/_WS/_WSVEICULO"
    "/var/log/life/_WS/_ESCALA"
    "/var/log/life/_WS/_ESCALA/_GERACAO"
    "/var/log/life/_WS/_ESCALA/_GERACAO/_LOG"
    "/var/log/life/_WS/_ESCALA/_GERACAO/_ERRO"
    "/var/log/life/_WS/_ESCALA/_ANALISE"
    "/var/log/life/_WS/_ESCALA/_ANALISE/_ERRO"
    "/var/log/life/_WS/_MNTDISPONIBILIDADE"
    "/var/log/life/_WS/_MNTDISPONIBILIDADE/_ERRO"
    "/var/log/life/_WS/_JOR_KM"
    "/var/log/life/_WS/_JOR_KM/_ERRO"
    "/var/log/life/_WS/_BUSEVENT"
    "/var/log/life/_WS/_BUSEVENT/_ERRO"
    "/var/log/life/_WS/_RAST_HIST"
    "/var/log/life/_WS/_RAST_HIST/_ERRO"
    "/var/log/life/_WS/_CONTROLEDEPNEUS"
    "/var/log/life/_WS/_CONTROLEDEPNEUS/_ERRO"
    "/var/log/life/_WS/_PC_MOV"
    "/var/log/life/_WS/_PC_MOV/_ERRO"
    "/var/log/life/_WS/_VEICULO"
    "/var/log/life/_WS/_VEICULO/_ERRO"
    "/var/log/life/_WS/_ERRO"
    "/var/log/life/_WS/_BUSLOCATION"
    "/var/log/life/_WS/_BUSLOCATION/_ERRO"
    "/var/log/life/_WS/_PROFROTAS"
    "/var/log/life/_WS/_PROFROTAS/_IMPORTACAO"
    "/var/log/life/_WS/_PROFROTAS/_ERRO"
    "/var/log/life/_WS/_BUSTRIP"
    "/var/log/life/_WS/_BUSTRIP/_SQL"
    "/var/log/life/_WS/_BUSTRIP/_ERRO"
    "/var/log/life/_WS/_RAST_ONLINE_VEICULO"
    "/var/log/life/_WS/_RAST_ONLINE_VEICULO/_ERRO"
    "/var/log/life/_GLOBALSTAR"
    "/var/log/life/_GLOBALSTAR/_FLUXO"
    "/var/log/life/_GLOBALSTAR/_ERRO"
    "/var/log/life/_SOAP"
    "/var/log/life/_SOAP/_PROCESSAMENTO"
    "/var/log/life/_SOAP/_CHAMADAS"
    "/var/log/life/_WH"
    "/var/log/life/_WH/logs_ERRO"
    "/var/log/life/_WH/_ERRO"
)

echo "Criando diretórios..."
for pasta in "${PASTAS[@]}"; do
    mkdir -p "$pasta"
    if [ $? -eq 0 ]; then
        echo "✓ Criado: $pasta"
    else
        echo "✗ Erro ao criar: $pasta"
    fi
done

echo ""
echo "Aplicando permissões..."
chmod -R 777 "$BASE_DIR"
chown -R www-data:www-data "$BASE_DIR"

echo ""
echo "Verificando permissões..."
ls -la "$BASE_DIR" | head -10
echo "..."
echo "Concluído! Todas as pastas foram criadas e as permissões configuradas."


echo "-----------------------------------------------------------------------"
echo " "

echo "Criando diretórios do www"

# Criar /var/www/ se não existir
if [ ! -d "/var/www/" ]; then
    mkdir -p "/var/www/"
    echo "✓ Criado: /var/www/"
else
    echo "✓ Já existe: /var/www/"
fi

# Criar /var/www/empresas/ se não existir
if [ ! -d "/var/www/empresas/" ]; then
    mkdir -p "/var/www/empresas/"
    echo "✓ Criado: /var/www/empresas/"
else
    echo "✓ Já existe: /var/www/empresas/"
fi

echo ""
echo "Aplicando permissões..."

# Aplicar permissões 777 recursivamente
chmod -R 777 "/var/www/"
echo "✓ Permissões 777 aplicadas em /var/www/"

# Aplicar dono/grupo www-data recursivamente
chown -R www-data:www-data "/var/www/"
echo "✓ Dono/grupo www-data:www-data aplicado em /var/www/"

echo ""
echo "Verificando permissões..."
ls -la "/var/www/" | head -10

echo ""
echo "Concluído! Pastas criadas e permissões configuradas."


echo "-----------------------------------------------------------------------"
echo " "

# Script para instalar e configurar o Samba com as configurações especificadas

echo "Instalando o Samba..."
sudo apt update
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

sudo smbpasswd -a USUARIO2 <<EOF
SENHA
SENHA
EOF

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

echo "(!) Script finalizado - instalado samba, criado pastas de log e para o sistema"
