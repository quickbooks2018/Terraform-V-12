#!/bin/bash
# Purpose: Vault Dynamic Credentials Usage in actual production
# Maintainer: DevOps Muhammad Asim <quickbooks2018@gmail.com>

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