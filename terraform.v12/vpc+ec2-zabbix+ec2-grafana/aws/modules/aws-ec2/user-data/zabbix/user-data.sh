#!/bin/bash
#Purpose: Monitoring
#App: Zabbix
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


# Start empty MySQL server instance
docker volume create zabbix-mysql
docker volume create zabbix-mysql-conf
docker run --name mysql-server -t  --restart unless-stopped --network monitoring \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="123456789" \
      -v zabbix-mysql:/var/lib/mysql \
      -v zabbix-mysql-conf:/etc/mysql/conf.d \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -id mysql:8.0 \
      --character-set-server=utf8 --collation-server=utf8_bin \
      --default-authentication-plugin=mysql_native_password

# Start Zabbix Java gateway instance
docker run --name zabbix-java-gateway -t --network monitoring \
      --restart unless-stopped \
      -d zabbix/zabbix-java-gateway:latest

# Start Zabbix server instance and link the instance with created MySQL server instance
docker volume create zabbix-conf
docker run --name zabbix-server-mysql -t --network monitoring \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="123456789" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
      -v zabbix-conf:/etc/zabbix \
      --link mysql-server:mysql \
      --link zabbix-java-gateway:zabbix-java-gateway \
      -p 10051:10051 \
      --restart unless-stopped \
      -d zabbix/zabbix-server-mysql:latest

# Start Zabbix web interface and link the instance with created MySQL server and Zabbix server instances
docker run --name zabbix-web-nginx-mysql -t --network monitoring \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="123456789" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      --link mysql-server:mysql \
      --link zabbix-server-mysql:zabbix-server \
      -p 80:8080 \
      --restart unless-stopped \
      -d zabbix/zabbix-web-nginx-mysql:latest

# Docker remove all containers
# docker rm -f $(docker ps -aq)