#!/bin/bash

# Docker installation

yum install -y docker

systemctl start docker

systemctl enable docker


#END
