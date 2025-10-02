#Altere os parametros de memoria, cpu , hostname e ip

docker run --name zabbix-agent -e ZBX_HOSTNAME="XLifewebNovo 43" -e ZBX_SERVER_HOST="192.168.2.1" --restart unless-stopped  -m 8196M --cpus 4.0 --privileged  --init -d zabbix/zabbix-agent:alpine-5.0-latest
