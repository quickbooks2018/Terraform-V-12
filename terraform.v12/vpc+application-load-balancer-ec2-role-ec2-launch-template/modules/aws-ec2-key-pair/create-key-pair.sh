#!/bin/bash

ssh-keygen -f rabbitmq
ssh-keygen -f rabbitmq -e -m pem
mv rabbitmq rabbitq.pem


#END