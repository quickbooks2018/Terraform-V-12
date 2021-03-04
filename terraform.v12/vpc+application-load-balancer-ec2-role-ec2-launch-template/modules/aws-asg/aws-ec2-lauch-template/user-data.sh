#!/bin/bash
# OS: AmazonLinux
# Purpose: Rabbitmq Cluster Setup on AWS EC2 in docker
# Maintainer: cloudgeeks.ca
# https://www.rabbitmq.com/cluster-formation.html#peer-discovery-classic-config
# https://www.rabbitmq.com/cluster-formation.html#peer-discovery-aws
# https://hub.docker.com/_/rabbitmq
# https://github.com/docker-library/rabbitmq/issues/61
# https://www.rabbitmq.com/clustering.html
# Note: Make sure to TAG the EC2 Auto-Scaling Gourp EC2 with --->           service rabbitmq             <--- cluster_formation.aws.instance_tags.service = rabbitmq

# Docker Installation
yum install -y docker
systemctl start docker
systemctl enable docker

# NETCAT installation
yum install -y nc

# USERADD
useradd rabbitmq
mkdir -p /root/rabbitmq


# variables section
environment="dev"
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep -oP '\"region\"[[:space:]]*:[[:space:]]*\"\K[^\"]+')
export AWS_DEFAULT_REGION=$region
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
export hostName
user="asim"
password="asim"
ipV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# Rabbitmq Configurations
echo "
cluster_formation.peer_discovery_backend = aws
cluster_formation.aws.region = "$region"
cluster_formation.aws.use_autoscaling_group = true
cluster_formation.discovery_retry_limit = 10
cluster_formation.discovery_retry_interval = 10000
cluster_formation.aws.instance_tags.service = rabbitmq
cluster_formation.aws.use_private_ip = false
cluster_name = cloudgeeks
log.file.level = debug
vm_memory_high_watermark.relative = 0.8
" > /root/rabbitmq/rabbitmq.conf



echo "
NODENAME=rabbit@"$HOSTNAME"
NODE_IP_ADDRESS="$ipV4"
USE_LONGNAME=true
" > /root/rabbitmq/rabbitmq-env.conf

chmod 666 /root/rabbitmq/rabbitmq-env.conf

cat > /root/rabbitmq/enabled_plugins <<'EOF'
[rabbitmq_management,rabbitmq_peer_discovery_aws,rabbitmq_federation,rabbitmq_prometheus].
EOF



chown -R rabbitmq:rabbitmq rabbitmq

chmod 777 -R /root/rabbitmq

docker run  --restart unless-stopped --name rabbit --network="host" -v /root/rabbitmq:/etc/rabbitmq --hostname $HOSTNAME -e RABBITMQ_NODENAME=rabbit@"$HOSTNAME" -e NODE_IP_ADDRESS="$ipV4" -e RABBITMQ_USE_LONGNAME=true -e RABBITMQ_DEFAULT_USER=${user} -e RABBITMQ_ERLANG_COOKIE=CLOUDGEEKSCA -e RABBITMQ_DEFAULT_PASS=${password} -e RABBITMQ_DEFAULT_VHOST=cloudgeeks --log-opt max-size=1m --log-opt max-file=1 quickbooks2018/rabbitmq:latest
while ! nc -vz 127.0.0.1 5672;do echo "Waiting for port" && sleep 5;done


while ! nc -vz 127.0.0.1 5672;do echo "Waiting for port" && sleep 5;done

sleep 30


# https://www.rabbitmq.com/parameters.html
# Note -p is VHOST ---> -e RABBITMQ_DEFAULT_VHOST=cloudgeeks    <<< if you do not set this environment variable RABBITMQ_DEFAULT_VHOST by default it is /
#docker exec -it rabbit rabbitmq-plugins enable rabbitmq_federation

sleep 30
# https://www.rabbitmq.com/vhosts.html
docker exec -it rabbit bash <<'EOF'
rabbitmqctl set_policy -p cloudgeeks ha-fed ".*" '{"federation-upstream-set":"all", "ha-sync-mode":"automatic","ha-mode":"all"}' --priority 1 --apply-to queues
EOF


#END
