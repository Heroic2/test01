#!/bin/bash
#
set -euo pipefail
sudo yum -y install epel*
sudo yum -y install nginx
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo cp ./nginx/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx
echo "请手动修改nginx.conf文件.\n"
