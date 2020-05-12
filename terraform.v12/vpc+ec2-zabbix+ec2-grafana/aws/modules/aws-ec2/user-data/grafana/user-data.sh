#!/bin/bash
#Purpose: Monitoring
#App: Grafana
#OS AmazonLinux/Ubuntu
#Maintainer DevOps Muhammad Asim <quickbooks2018@gmail.com>

# Docker Installation
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh      2>&1 > /dev/null
rm -rf get-docker.sh
yum install -y docker 2>&1 > /dev/null
systemctl start docker
systemctl enable docker

# Docker Compose Installation

curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

MONITORING=`docker network ls | awk '{print $2}' | grep -i "monitoring"`
if [ "0" == "$?" ]
then
  echo -e "\n Hey! docker network "$MONITORING" exists \n"
  else
    docker network create monitoring
    fi

docker volume create grafana-etc
docker volume create grafana
docker run -id --name=grafana --network monitoring --user root -v  grafana:/var/lib/grafana -v grafana-etc:/etc/grafana -p 3000:3000 grafana/grafana:latest
docker exec grafana grafana-cli plugins install alexanderzobnin-zabbix-app
docker restart grafana

#END

# Addtional Notes
# Zabbix API
# http://privateip/api_jsonrpc.php      # Eg: http://10.20.1.20/api_jsonrpc.php
# http://127.0.0.1/zabbix/api_jsonrpc.php # Eg: http://172.31.10.4/zabbix/api_jsonrpc.php