#!/bin/bash
#Aurthor: Muhammad Asim
#Purpose: EC2 Role Attachment for KMS Decryption


# Update Required
##########################################################
REGION="us-east-1"

ACCOUNT="362545035861"

KMS_KEY_ID="5b7d1d0d-624c-487d-869f-b8298529d678"

INSTANCE_PROFILE_NAME="kmsecryption"

ROLE_NAME="kmsecryption"

TRUST="ec2-trust-relationship"

KMS_POLICY_NAME="kmsecryption"

ALIAS="rds"

#############################################################


KMS_ARN="arn:aws:iam::$ACCOUNT:policy/$KMS_POLICY_NAME"




# AWSCLI Setup
apt update -y              2>&1 > /dev/null
apt  install awscli  -y     2>&1 > /dev/null
apt install python3-pip -y    2>&1 > /dev/null
pip3 install --upgrade --user awscli   2>&1 > /dev/null
aws --version


sleep 3

echo -e "\nNow we are going to Setup a Role for KMS EC2 Decryption\n"


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


cat << EOF > "$KMS_POLICY_NAME".json
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
                "arn:aws:kms:*:*:alias/$ALIAS",
                "arn:aws:kms:${REGION}:${ACCOUNT}:key/${KMS_KEY_ID}"
            ]
        }
    ]
}
EOF
aws iam create-policy --policy-name "$KMS_POLICY_NAME" --policy-document file://"$KMS_POLICY_NAME".json --description "Allows delegation of all KMS"



# 3. Attaching existing AWS Custom Policy For KMS

aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$KMS_ARN"



# 4. Run the following AWS CLI command to add the role to the instance profile:
aws iam add-role-to-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" --role-name "$ROLE_NAME"



# 5. Run the following AWS CLI command to attach the instance profile to the EC2 instance:
aws ec2 associate-iam-instance-profile --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" --instance-id "$INSTANCE_ID"



#END