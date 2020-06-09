#!/bin/bash
# Purpose: KMS Encryption & Decryption

# Create a Key from AWS Console

ALIAS_NAME_KMS_KEY_ID='5b7d1d0d-624c-487d-869f-b8298529d678'
RDS_USER='cloudgeeks.ca'
RDS_PASSWORD='123456789'
RDS_DATABASE_NAME='wordpress'

mkdir -p "$PWD"/secrets/wordpress

# Encryption


aws kms encrypt --region us-east-1 --key-id $ALIAS_NAME_KMS_KEY_ID  --plaintext $RDS_PASSWORD --output text --query CiphertextBlob | base64 --decode > "$PWD"/secrets/wordpress/wordpress-database-password.txt
aws kms encrypt --region us-east-1 --key-id $ALIAS_NAME_KMS_KEY_ID  --plaintext $RDS_DATABASE_NAME --output text --query CiphertextBlob | base64 --decode > "$PWD"/secrets/wordpress/wordpress-database-name.txt
aws kms encrypt --region us-east-1 --key-id $ALIAS_NAME_KMS_KEY_ID  --plaintext $RDS_USER --output text --query CiphertextBlob | base64 --decode > "$PWD"/secrets/wordpress/wordpress-database-user.txt




# Decryption

aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-password.txt --output text --query Plaintext | base64 --decode
aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-name.txt --output text --query Plaintext | base64 --decode
aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-user.txt --output text --query Plaintext | base64 --decode



WORDPRESS_DB_PASSWORD=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-password.txt --output text --query Plaintext | base64 --decode`
WORDPRESS_DB_NAME=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-name.txt --output text --query Plaintext | base64 --decode`
WORDPRESS_DB_USER=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-user.txt --output text --query Plaintext | base64 --decode`


# Export Environment Variables
#
#export WORDPRESS_DB_PASSWORD=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-password.txt --output text --query Plaintext | base64 --decode`
#export WORDPRESS_DB_NAME=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-name.txt --output text --query Plaintext | base64 --decode`
#export WORDPRESS_DB_USER=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-user.txt --output text --query Plaintext | base64 --decode`



echo -e "\nCredentials Decrypted\n"

echo " This is Wordpress Database Password            = $WORDPRESS_DB_PASSWORD "
echo " This is Wordpress Database Name                = $WORDPRESS_DB_NAME "
echo " This is Wordpress Database User                = $WORDPRESS_DB_USER "

#END
