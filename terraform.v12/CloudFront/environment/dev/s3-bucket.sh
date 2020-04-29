#!/bin/bash
# Purpose: Cloudfront Static WebSite
# Maintainer: Muhammad Asim

BUCKET_NAME=`terraform output | grep -i bucket-name | awk '{print $3}'`

LOGS="logs/"

APPLICATION_PATH="./webapp"



# Creating a directory inside our bucket

aws s3 ls | grep -i "$BUCKET_NAME"
echo $?

if [ "$?" = "0" ]
 then
   echo "Bucket "$BUCKET_NAME" exists"
   else
    echo "Bucket Not Found"
    exit
fi

aws s3api put-object --bucket $BUCKET_NAME --key $LOGS

aws s3 cp "$APPLICATION_PATH"  s3://"$BUCKET_NAME" --recursive



# END