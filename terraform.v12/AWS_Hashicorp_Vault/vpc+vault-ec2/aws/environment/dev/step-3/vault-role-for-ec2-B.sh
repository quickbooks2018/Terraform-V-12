#!/bin/bash
#Aurthor: Muhammad Asim
#Purpose: EC2 Role Attachment


REGION="us-east-1"

ACCOUNT="117519388977"

KMS_KEY_ID="16c183e5-f38b-43c6-afc2-4a891af21ddd"

INSTANCE_PROFILE_NAME="vault"

ROLE_NAME="vault"

TRUST="ec2-trust-relationship"

VAULT_KMS_POLICY_NAME="vault-kms"
VAULT_KMS_ARN="arn:aws:iam::$ACCOUNT:policy/$VAULT_KMS_POLICY_NAME"

DYNAMO_TABLE="cloudgeeks.ca-vault"
VAULT_DYNAMODB_POLICY_NAME="vault-dynamodb"
VAULT_DYNAMODB_POLICY_ARN="arn:aws:iam::$ACCOUNT:policy/$VAULT_DYNAMODB_POLICY_NAME"



# AWSCLI Setup
apt update -y
apt  install awscli  -y
apt install python3-pip -y
pip3 install --upgrade --user awscli
aws --version

echo -e "\nPlease Provide Your AWS Credentials\n"

aws configure

sleep 5

echo -e "\nNow we are going to Setup a Role for Hashicorp Vault\n"


read -p "Hi DevOps Muhammad Asim here, please provide me instanceID": INSTANCE_ID


# 1.    If you haven't already created an instance profile, run the following AWS CLI command:

aws iam create-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME


# 2. IAM Role creation & assume role

cat <<EOF > "$TRUST".json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document file://"$TRUST".json --description "EC2 Access"


cat << EOF > "$VAULT_KMS_POLICY_NAME".json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:DescribeCustomKeyStores",
                "kms:ListKeys",
                "kms:DeleteCustomKeyStore",
                "kms:GenerateRandom",
                "kms:UpdateCustomKeyStore",
                "kms:ListAliases",
                "kms:DisconnectCustomKeyStore",
                "kms:CreateKey",
                "kms:ConnectCustomKeyStore",
                "kms:CreateCustomKeyStore"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "kms:*",
            "Resource": [
                "arn:aws:kms:*:*:alias/*",
                "arn:aws:kms:${REGION}:${ACCOUNT}:key/${KMS_KEY_ID}"
            ]
        }
    ]
}

EOF
aws iam create-policy --policy-name "$VAULT_KMS_POLICY_NAME" --policy-document file://"$VAULT_KMS_POLICY_NAME".json --description "Allows delegation of all KMS"

cat << EOF > $VAULT_DYNAMODB_POLICY_NAME.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:DescribeLimits",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListTagsOfResource",
                "dynamodb:DescribeReservedCapacityOfferings",
                "dynamodb:DescribeReservedCapacity",
                "dynamodb:ListTables",
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:CreateTable",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:GetRecords",
                "dynamodb:PutItem",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:Scan",
                "dynamodb:DescribeTable"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:dynamodb:${REGION}:${ACCOUNT}:table/${DYNAMO_TABLE}"
            ]
        }
    ]
}


EOF
aws iam create-policy --policy-name "$VAULT_DYNAMODB_POLICY_NAME" --policy-document file://"$VAULT_DYNAMODB_POLICY_NAME".json --description "Allows delegation to Dynamodb"


# 3. Attaching existing AWS Custom Policy For Dynamodb & KMS

aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$VAULT_KMS_ARN"
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$VAULT_DYNAMODB_POLICY_ARN"


# 4. Run the following AWS CLI command to add the role to the instance profile:
aws iam add-role-to-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" --role-name "$ROLE_NAME"



# 5. Run the following AWS CLI command to attach the instance profile to the EC2 instance:
aws ec2 associate-iam-instance-profile --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" --instance-id "$INSTANCE_ID"



# END
