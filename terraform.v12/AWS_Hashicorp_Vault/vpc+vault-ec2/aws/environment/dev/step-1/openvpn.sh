#!/bin/bash
#Aurthor: Muhammad Asim
#Purpose: Setup OpenVPN in quick time

sudo apt update -y > /dev/null

sudo apt install -y curl > /dev/null

sudo curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null

sudo sh get-docker.sh > /dev/null

sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null

sudo chmod +x /usr/local/bin/docker-compose > /dev/null

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose > /dev/null


systemctl restart docker

systemctl enable docker



#We we are pulling the best Image of docker for OpenVPN on earth.

echo -e "\nWe we are pulling the best Image of OpenVPN for docker on earth by kylemanna/openvpn\n"

docker pull kylemanna/openvpn

#Step 1

echo -e "\nStep 1\n"
sleep 1
echo -e "\nPerforming Step 1, we are going to make a directory at /root/OpenVPN/openvpn_data\n"

mkdir -p /root/OpenVPN/openvpn_data


OVPN_DATA=/root/OpenVPN/openvpn_data

echo -e "\n$OVPN_DATA\n"

export OVPN_DATA

sleep 1
read -p "Please enter your Server Main IP Address IP: " IP

echo -e "\nYour Server IP is $IP\n"

#Step 2
echo -e "\nStep 2\n"
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$IP


echo -e "\nAfter a Shortwhile You need to enter your Server Secure Password details please wait ...\n"

#Step 3
sleep 3

echo -e "\nWe are now at Step 3\n"

docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki



#Step 4
sleep 1
echo -e "\nStep 4, We are Starting OpenVPN server process please wait ...\n"

docker run --name OpenVPN -v $OVPN_DATA:/etc/openvpn -d -p 23525:1194/udp --restart unless-stopped --cap-add=NET_ADMIN kylemanna/openvpn

sleep 3

echo "\nSee I am up and running Alhumdulliah\n"

docker ps -a

echo -e "\nMy name is OpenVPN, I am running inside the container name OpenVPN\n"

sleep 3

#Step 5
echo -e "\nWe are now at 5th Step, Generate a client certificate with  a passphrase SAME AS YOU GIVE FOR SERVER...PASSPHRASE please wait...\n"

sleep 1
read -p "Please Provide Your Client Name " CLIENTNAME

echo -e "\nI am adding a client with name $CLIENTNAME\n"

#docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENTNAME nopass

docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENTNAME

#Step 6
echo -e "\nWe are now at 6TH Step, don't worry this is last step, you lazy GUY,Now we retrieve the client configuration with embedded certificates\n"


echo -e "\n$CLIENTNAME ok\n"

docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn



#Note: If you remove the docker container by mistake, simply copy and paster 4TH Step, all will set as previously.

#END