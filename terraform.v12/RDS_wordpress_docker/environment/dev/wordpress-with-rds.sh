#!/bin/bash
# Purpose: docker-demo Wordpress with RDS
# Maintainer: DevOps Muhammad Asim <quickbooks2018@gmail.com>




# Wordpress Application Setup in docker-demo


WORDPRESS_DB_HOST="vault.cxqbmqcwfxq5.us-east-1.rds.amazonaws.com"

# Decryption

WORDPRESS_DB_PASSWORD=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-password.txt --output text --query Plaintext | base64 --decode`
WORDPRESS_DB_NAME=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-name.txt --output text --query Plaintext | base64 --decode`
WORDPRESS_DB_USER=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-user.txt --output text --query Plaintext | base64 --decode`



docker-demo run --name wordpress -e WORDPRESS_DB_HOST="vault.cxqbmqcwfxq5.us-east-1.rds.amazonaws.com" -e WORDPRESS_DB_NAME="$WORDPRESS_DB_NAME" -e WORDPRESS_DB_PASSWORD="$WORDPRESS_DB_PASSWORD" -e WORDPRESS_DB_USER="$WORDPRESS_DB_USER" -p 80:80 --restart unless-stopped -d wordpress



#END