#!/bin/bash
# Purpose: ecs Wordpress with RDS
# Maintainer: DevOps Muhammad Asim <quickbooks2018@gmail.com>
# Warning with RDS ---> Do not use the default mysql Database

### First Step ###
# Create a new database
# ---> CREATE DATABASE wordpress;




# Wordpress Application Setup in ecs


WORDPRESS_DB_HOST="vault.cxqbmqcwfxq5.us-east-1.rds.amazonaws.com"

# Decryption

WORDPRESS_DB_PASSWORD=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-password.txt --output text --query Plaintext | base64 --decode`
WORDPRESS_DB_NAME=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-name.txt --output text --query Plaintext | base64 --decode`
WORDPRESS_DB_USER=`aws kms decrypt --region us-east-1 --ciphertext-blob fileb://"$PWD"/secrets/wordpress/wordpress-database-user.txt --output text --query Plaintext | base64 --decode`



docker run --name wordpress -e WORDPRESS_DB_HOST="$WORDPRESS_DB_HOST" -e WORDPRESS_DB_NAME="$WORDPRESS_DB_NAME" -e WORDPRESS_DB_PASSWORD="$WORDPRESS_DB_PASSWORD" -e WORDPRESS_DB_USER="$WORDPRESS_DB_USER" -p 80:80 --restart unless-stopped -d wordpress



#END
