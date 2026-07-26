#!/bin/bash

sudo apt-get update
sudo apt-get install -y git
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
git clone https://github.com/gurpal-04/DevOps-Course.git

cd DevOps-Course/Docker/frontend
docker build -t frontend .
docker run -d -p 3000:3000 frontend
docker run -d -p 3000:3000 -e BACKEND_PUBLIC_IP="${BACKEND_PUBLIC_IP}" frontend