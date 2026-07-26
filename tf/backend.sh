#!/bin/bash

sudo apt-get update
sudo apt-get install -y git
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
git clone https://github.com/gurpal-04/DevOps-Course.git

cd DevOps-Course/Docker/backend
docker build -t backend .
docker run -d -p 5000:5000 backend