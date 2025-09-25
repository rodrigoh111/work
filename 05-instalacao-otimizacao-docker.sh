#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script precisa ser executado como root ou com sudo"
    exit 1
fi

# Pacotes seguros para remover
PACOTES_SEGUROS=(
    "gnome-mahjongg" "gnome-mines" "gnome-sudoku" "aisleriot"
    "thunderbird" "rhythmbox" "simple-scan" "cheese"
    "example-content" "popularity-contest" "apport"
    "whoopsie" "ubuntu-report" "deja-dup" "gnome-orca"
    "gnome-chess" "snapd" "snap-confine" "gnome-software-plugin-snap"
    "transmission-common" "gnome-user-docs" "yelp" "totem"
    "gnome-software" "update-notifier" "zeitgeist"
    "speech-dispatcher" "brltty"
)

# Função para remover pacotes
remover_pacotes() {
    print_status "Removendo pacotes desnecessários..."
    
    for pacote in "${PACOTES_SEGUROS[@]}"; do
        if dpkg -l | grep -q "^ii  $pacote "; then
            print_status "Removendo: $pacote"
            apt-get remove --purge -y "$pacote" 2>/dev/null
        fi
    done
    
    # Limpar dependências não usadas
    apt-get autoremove -y
    apt-get autoclean -y
}

# Função para instalar Docker
instalar_docker() {
    print_status "Instalando Docker..."
    
    # Remover versões antigas
    apt-get remove -y docker docker-engine docker.io containerd runc
    
    # Instalar dependências
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common
    
    # Adicionar repositório oficial do Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Instalar Docker
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    print_status "Docker instalado com sucesso!"
}

# Função para instalar Docker Compose
instalar_docker_compose() {
    print_status "Instalando Docker Compose..."
    
    # Determinar a última versão estável
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Download e instalação do Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Criar link simbólico para uso geral
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    # Verificar instalação
    if docker-compose --version; then
        print_status "Docker Compose ${COMPOSE_VERSION} instalado com sucesso!"
    else
        print_error "Falha na instalação do Docker Compose"
        exit 1
    fi
}

# Função para configurar data-root personalizado
configurar_data_root() {
    print_status "Configurando data-root personalizado para Docker"
    
    echo ""
    print_info "O data-root padrão é: /var/lib/docker"
    print_info "Este diretório armazena todas as imagens, containers e volumes"
    print_info "Recomendo usar um disco separado com bastante espaço"
    echo ""
    
    read -p "Digite o caminho completo para o novo data-root (ex: /mnt/volumes/docker): " DATA_ROOT_PATH
    
    if [ -z "$DATA_ROOT_PATH" ]; then
        print_error "Caminho não pode ser vazio!"
        return 1
    fi
    
    # Criar diretório se não existir
    mkdir -p "$DATA_ROOT_PATH"
    chmod 711 "$DATA_ROOT_PATH"
    
    # Parar Docker
    print_status "Parando serviço Docker..."
    systemctl stop docker
    
    # Backup dos dados existentes
    if [ -d "/var/lib/docker" ] && [ ! -L "/var/lib/docker" ]; then
        print_status "Fazendo backup dos dados existentes..."
        BACKUP_DIR="/var/lib/docker.backup.$(date +%Y%m%d_%H%M%S)"
        mv /var/lib/docker "$BACKUP_DIR"
        print_info "Backup criado em: $BACKUP_DIR"
    fi
    
    # Criar configuração do daemon
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << EOF
{
  "data-root": "$DATA_ROOT_PATH",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
    
    # Iniciar Docker
    print_status "Iniciando Docker com novo data-root..."
    systemctl start docker
    
    # Aguardar inicialização
    sleep 5
    
    # Verificar se funcionou
    if docker info 2>/dev/null | grep -q "Docker Root Dir: $DATA_ROOT_PATH"; then
        print_status "✅ Data-root configurado com sucesso em: $DATA_ROOT_PATH"
        
        # Mostrar informações do disco
        echo ""
        print_info "Informações do disco:"
        df -h "$DATA_ROOT_PATH"
        echo ""
        
    else
        print_error "❌ Falha na configuração do data-root!"
        print_warning "Restaurando configuração original..."
        rm -f /etc/docker/daemon.json
        if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
            mv "$BACKUP_DIR" /var/lib/docker
        fi
        systemctl start docker
        return 1
    fi
}

# Função para configurar data-root do Docker Compose
configurar_data_root_compose() {
    print_status "Configurando data-root para Docker Compose..."
    
    echo ""
    print_info "Docker Compose usa o mesmo data-root do Docker"
    print_info "Mas você pode configurar volumes específicos no docker-compose.yml"
    print_info "Exemplo no docker-compose.yml:"
    echo ""
    echo "volumes:"
    echo "  meus-dados:"
    echo "    driver: local"
    echo "    driver_opts:"
    echo "      type: none"
    echo "      device: /mnt/volumes/meus-dados"
    echo "      o: bind"
    echo ""
    
    read -p "Deseja criar um diretório padrão para volumes do Docker Compose? (s/N): " CRIAR_DIR_COMPOSE
    if [[ $CRIAR_DIR_COMPOSE =~ ^[Ss]$ ]]; then
        read -p "Digite o caminho para volumes do Docker Compose (ex: /mnt/volumes/docker-compose): " COMPOSE_DATA_PATH
        
        if [ -n "$COMPOSE_DATA_PATH" ]; then
            mkdir -p "$COMPOSE_DATA_PATH"
            chmod 755 "$COMPOSE_DATA_PATH"
            chown -R root:docker "$COMPOSE_DATA_PATH"
            print_status "Diretório para Docker Compose criado: $COMPOSE_DATA_PATH"
        fi
    fi
}

# Função para otimizar sistema
otimizar_sistema() {
    print_status "Otimizando sistema para Docker..."
    
    # Configurar limites do sistema
    cat > /etc/sysctl.d/99-docker.conf << EOF
# Otimizações para Docker
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.ip_local_port_range = 1024 65535
vm.swappiness = 10
vm.overcommit_memory = 1
EOF
    
    sysctl -p /etc/sysctl.d/99-docker.conf
    
    # Configurar limites de arquivos
    echo "* soft nofile 65536" >> /etc/security/limits.conf
    echo "* hard nofile 65536" >> /etc/security/limits.conf
    echo "* soft nproc 65536" >> /etc/security/limits.conf
    echo "* hard nproc 65536" >> /etc/security/limits.conf
    
    # Adicionar usuário ao grupo docker
    if id -u "$SUDO_USER" >/dev/null 2>&1; then
        usermod -aG docker "$SUDO_USER"
        print_status "Usuário $SUDO_USER adicionado ao grupo docker"
    fi
}

# Função para mostrar resumo da instalação
mostrar_resumo() {
    echo ""
    print_status "=== RESUMO DA INSTALAÇÃO ==="
    print_info "Docker instalado: $(docker --version 2>/dev/null || echo 'Não instalado')"
    print_info "Docker Compose instalado: $(docker-compose --version 2>/dev/null || echo 'Não instalado')"
    
    if [ -f "/etc/docker/daemon.json" ]; then
        DOCKER_ROOT=$(docker info 2>/dev/null | grep 'Docker Root Dir' | cut -d: -f2 | tr -d ' ')
        print_info "Data-root configurado: ${DOCKER_ROOT:-/var/lib/docker (padrão)}"
    else
        print_info "Data-root: /var/lib/docker (padrão)"
    fi
    
    # Mostrar espaço em disco
    echo ""
    print_info "Espaço em disco disponível:"
    df -h / /var/lib/docker /mnt/volumes 2>/dev/null || df -h /
    
    echo ""
    print_warning "⚠️  Para aplicar as mudanças de grupo, faça logout e login novamente"
    print_warning "⚠️  Ou execute: newgrp docker"
}

# Função principal
main() {
    print_status "Iniciando otimização do Ubuntu Server para Docker + Docker Compose"
    
    # Atualizar sistema
    print_status "Atualizando sistema..."
    apt-get update
    apt-get upgrade -y
    
    # Remover pacotes desnecessários
    remover_pacotes
    
    # Instalar Docker
    instalar_docker
    
    # Instalar Docker Compose
    instalar_docker_compose
    
    # Configurar data-root do Docker
    echo ""
    read -p "Deseja configurar um data-root personalizado para o Docker? (s/N): " CONFIG_DATA_ROOT
    if [[ $CONFIG_DATA_ROOT =~ ^[Ss]$ ]]; then
        configurar_data_root
    else
        print_warning "Usando data-root padrão (/var/lib/docker)"
    fi
    
    # Configurar data-root para Docker Compose
    configurar_data_root_compose
    
    # Otimizar sistema
    otimizar_sistema
    
    # Limpar cache
    print_status "Limpando cache..."
    apt-get clean
    docker system prune -f 2>/dev/null || true
    
    # Mostrar resumo
    mostrar_resumo
    
    print_status "✅ Otimização concluída com sucesso!"
    print_warning "Recomendado: Reiniciar o sistema para aplicar todas as otimizações"
}

# Executar função principal
main "$@"
