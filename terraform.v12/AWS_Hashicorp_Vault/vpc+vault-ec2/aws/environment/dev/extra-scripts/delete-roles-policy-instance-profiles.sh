#!/bin/bash
#Aurthor: Muhammad Asim
#Purpose: EC2 Role Attachment


REGION="us-east-1"

ACCOUNT="645019199348"

KMS_KEY_ID="c1861a36-b6d5-4e37-8a72-b9e15dea7c9f"

INSTANCE_PROFILE_NAME="vault"

ROLE_NAME="vault"

VAULT_KMS_POLICY_NAME="vault-kms"
VAULT_KMS_ARN="arn:aws:iam::$ACCOUNT:policy/$VAULT_KMS_POLICY_NAME"

VAULT_DYNAMODB_POLICY_NAME="vault-dynamodb"
VAULT_DYNAMODB_POLICY_ARN="arn:aws:iam::$ACCOUNT:policy/$VAULT_DYNAMODB_POLICY_NAME"

# UnAttach from EC2
aws iam remove-role-from-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" --role-name "$ROLE_NAME"

# Delete Instance Profile
aws iam delete-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME"

# UnAttach Policies
aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$VAULT_KMS_ARN"

aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$VAULT_DYNAMODB_POLICY_ARN"


# Delete Policy
aws iam delete-policy --policy-arn "$VAULT_KMS_ARN"
aws iam delete-policy --policy-arn "$VAULT_DYNAMODB_POLICY_ARN"

# Delete IAMRole
aws iam delete-role --role-name "$ROLE_NAME"












# END
