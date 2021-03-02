#!/bin/bash
# Purpose: RabbitMQ Cluster on AWS
# OS: AmazonLinux
# https://www.rabbitmq.com/configure.html
# https://www.rabbitmq.com/cluster-formation.html#peer-discovery-aws
# https://hub.docker.com/_/rabbitmq
# https://github.com/docker-library/rabbitmq/issues/61

# Cluster
# https://www.rabbitmq.com/clustering.html

# Variables --------------------------------------------------------------------> Hey! Please Update me
hostname="rabbit-1.cloudgeeks.ca"
hostedzoneid="Z0155344WOQ603Y4HMQL"

# Docker Installation
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker


# Configurations

mkdir -p rabbitmq/config

cat > rabbitmq/config/rabbitmq.conf <<'EOF'
loopback_users.guest = false
listeners.tcp.default = 5672

cluster_formation.peer_discovery_backend = rabbit_peer_discovery_classic_config
cluster_formation.classic_config.nodes.1 = rabbit@rabbit-1.cloudgeeks.ca
cluster_formation.classic_config.nodes.2 = rabbit@rabbit-2.cloudgeeks.ca
cluster_formation.classic_config.nodes.3 = rabbit@rabbit-3.cloudgeeks.ca
EOF



# Docker run

docker run --name $hostname --network host -e RABBITMQ_NODENAME=rabbit@"$hostname" -e RABBITMQ_ERLANG_COOKIE=CLOUDGEEKS -e RABBITMQ_DEFAULT_USER="asim" -e RABBITMQ_DEFAULT_PASS="asim" -e RABBITMQ_USE_LONGNAME=true --hostname "$hostname" -p 15672:15672 --restart unless-stopped -id rabbitmq:management

cd rabbitmq/config

sleep 10

chmod 666 rabbitmq.conf

docker cp rabbitmq.conf "$hostname":/etc/rabbitmq

#enable federation plugin

sleep 20

docker exec -it $hostname rabbitmq-plugins enable rabbitmq_federation

#mirror policy

sleep 30

docker exec -it $hostname rabbitmqctl set_policy ha-fed ".*" '{"federation-upstream-set":"all", "ha-sync-mode":"automatic","ha-mode":"nodes", "ha-params":["rabbit@rabbit-1.cloudgeeks.ca","rabbit@rabbit-2.cloudgeeks.ca","rabbit@rabbit-3.cloudgeeks.ca"]}' --priority 1 --apply-to queues

#  Cluster Master Node

docker exec -it $hostname rabbitmqctl stop_app

docker exec -it $hostname rabbitmqctl reset

docker exec -it $hostname rabbitmqctl start_app



#Producer application

#docker run --name producer -it --rm --network host -e RABBIT_HOST="$HOSTNAME" -e RABBIT_PORT=5672 -e RABBIT_USERNAME=asim -e RABBIT_PASSWORD=asim -p 8080:80 quickbooks2018/rabbitmq-producer:latest

#curl -X POST http://localhost:80/publish/cloudgeeks.ca

#curl -X POST http://localhost:80/publish/asim

#Consumer application

#docker run --name consumer -it --rm --network rabbits -e RABBIT_HOST="$HOSTNAME" -e RABBIT_PORT=5672 -e RABBIT_USERNAME=asim -e RABBIT_PASSWORD=asim quickbooks2018/rabbitmq-consumer:latest

# Route53 Section

localip=$(curl -fs http://169.254.169.254/latest/meta-data/local-ipv4)
file=/tmp/record.json

#  API Service

cat << EOF > $file
{
  "Comment": "Update the A record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$hostname",
        "Type": "A",
        "TTL": 10,
        "ResourceRecords": [
          {
            "Value": "$localip"
          }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id $hostedzoneid --change-batch file://$file

#END