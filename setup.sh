#!/bin/bash
echo "##### CLEAN DOCKER ENVIRONNEMENT #################"
sudo docker kill $(sudo docker ps -qa)
sudo docker rm $(sudo docker ps -qa)

echo "##### BUILD APACHE STATIC SERVER IMAGE #################"
sudo docker build -t res/apache-php ./docker-images/apache-php-image/

echo "##### BUILD EXPRESS JS DYNAMIC FUNNY PEOPLES APP #################"
sudo docker build -t res/express-js ./docker-images/express-image/

echo "##### BUILD APACHE REVERSE PROXY #################"
sudo docker build -t res/apache_rp ./docker-images/apache-reverse-proxy-image/

echo "##### RUN APACHE AND EXPRESS SERVERS CONTAINERS #################"
sudo docker run -d res/apache-php
sudo docker run -d res/apache-php
sudo docker run -d res/apache-php
sudo docker run -d --name apache-static res/apache-php

sudo docker run -d res/express-js
sudo docker run -d res/express-js
sudo docker run -d res/express-js
sudo docker run -d --name express-dynamic res/express-js

echo "##### RUN REVERSE PROXY CONTAINER #################"
static_ip=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' apache-static`
dynamic_ip=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' express-dynamic`
echo "Static IP = $static_ip"
echo "Dynamic IP = $dynamic_ip"
sudo docker run -d -e STATIC_APP=$static_ip:80 -e DYNAMIC_APP=$dynamic_ip:3000 --name apache_rp -p 8080:80 res/apache_rp


echo "##### CREATING DOCKER VOLUME FOR MANAGING CONTAINERS AND IMAGES #################"
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
