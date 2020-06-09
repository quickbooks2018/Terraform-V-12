#!/bin/bash
#Purpose: LAMP Stack
#App: Wordpress
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

NETWORK=`docker network ls | awk '{print $2}' | grep -i "cloudgeeks.ca"`
if [ "0" == "$?" ]
then
  echo -e "\n Hey! docker network "$NETWORK" exists \n"
  else
    docker network create cloudgeeks.ca
    fi

# Mariadb Setup
docker volume create mariadb
docker run --name mariadb -e MARIADB_DATABASE=bitnami_wordpress -e MARIADB_ROOT_PASSWORD="ausdermoitoeuropas" -v mariadb:/bitnami --network="cloudgeeks.ca" --restart unless-stopped -d bitnami/mariadb:latest

# Phpmyadmin Setup
docker run --name phpmyadmin --network="cloudgeeks.ca" --link mariadb:db -id -p 8080:80 --restart unless-stopped phpmyadmin/phpmyadmin


# Wordpress Setup
docker volume create wordpress
docker run --name bitnami-wordpress --network="cloudgeeks.ca" -e WORDPRESS_DATABASE_NAME="bitnami_wordpress" -e WORDPRESS_DATABASE_USER="root" -e WORDPRESS_DATABASE_PASSWORD="ausdermoitoeuropas" --link mariadb:db  -v wordpress:/bitnami --restart unless-stopped -d bitnami/wordpress:latest




# Nginx Container

mkdir -p ~/ssl/certs

#2
mkdir -p ~/nginx/conf.d

#3
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/ssl/certs/nginx-selfsigned.key -out ~/ssl/certs/nginx-selfsigned.crt
openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -keyout ~/ssl/certs/nginx-selfsigned.key \
    -out ~/ssl/certs/nginx-selfsigned.crt
#4
openssl dhparam -out ~/ssl/certs/dhparam.pem 2048

#5
cd ~/nginx/conf.d

#6
apt update -y  2> /dev/null
apt install -y vim 2> /dev/null
yum update -y  2> /dev/null
yum install -y vim 2> /dev/null

#7
echo '
server {
  listen 80;
  server_name wordpress.saqlainmushtaq.com;
  return 301 https://$host$request_uri;
}
server {
  server_name wordpress.saqlainmushtaq.com;
  listen 443 ssl;
  ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
  ssl_certificate_key /etc/ssl/certs/nginx-selfsigned.key;
  ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers    TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:TLS-AES-128-GCM-SHA256:HIGH:!aNULL:!MD5;
location / {
    proxy_set_header        Host $host:$server_port;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_redirect http:// https://;
    proxy_pass              http://bitnami-wordpress:8080;
    # Required for new HTTP-based CLI
    proxy_http_version 1.1;
    proxy_request_buffering off;
       }
}' >  ~/nginx/conf.d/server.conf

#8
docker run --name nginx --network=cloudgeeks.ca --restart unless-stopped -v ~/ssl/certs:/etc/ssl/certs -v ~/nginx/conf.d:/etc/nginx/conf.d -p 443:443 -p 80:80 -d nginx


#END
