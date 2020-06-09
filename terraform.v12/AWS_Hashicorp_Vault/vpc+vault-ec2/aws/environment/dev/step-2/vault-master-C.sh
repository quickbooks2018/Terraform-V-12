#!/bin/bash
#Aurthor: Muhammad Asim
#Purpose: Vault Master Setup

# STEP-1

# DynamoDB Table Creation

REGION="us-east-1"
dynamodbTable="cloudgeeks.ca-vault"
domain="cloudgeeks.ca"
kms_key_arn="arn:aws:kms:us-east-1:117519388977:key/16c183e5-f38b-43c6-afc2-4a891af21ddd"
api_addr="https://10.20.4.144:8200"
cluster_addr="https://10.20.4.144:8201"


# Downloading the latest Hashicorp vault
curl -# -LO https://releases.hashicorp.com/vault/1.4.1/vault_1.4.1_linux_amd64.zip
apt install -y unzip
unzip vault_1.4.1_linux_amd64.zip
cp vault /usr/local/bin/
rm -rf vault_1.4.1_linux_amd64.zip
rm -rf vault
vault --version

# vault.hcl ---> configuration for dynamodb
mkdir /etc/vault.d

cat << EOF > /etc/vault.d/vault.hcl
storage "dynamodb" {
  ha_enabled = "true"
  region     = "$REGION"
  table      = "$dynamodbTable"
   advertise_addr = "http://127.0.0.1:8200"
  read_capacity  = "5"
  write_capacity = "5"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/root/tls/$domain.crt"
  tls_key_file  = "/root/tls/$domain.key"
}
seal "awskms" {
  region = "$REGION"
  kms_key_id = "$kms_key_arn"
}
ui=true
api_addr = "$api_addr"
cluster_addr = "$cluster_addr"
EOF

cat << EOF > /etc/systemd/system/vault.service

[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

[Service]
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
StandardOutput=syslog
StandardError=syslog
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start vault
systemctl enable vault
systemctl status vault

# # SETUP Persistent environment variables in Ubuntu
#/etc/profile.d/*.sh

cat << EOF > /etc/profile.d/vault_environment_variables.sh
export VAULT_ADDR="$cluster_addr"
export VAULT_CACERT="/root/tls/CA.crt"
EOF
export VAULT_CACERT="/root/tls/CA.crt"
chmod +x /etc/profile.d/vault_environment_variables.sh

# END