#!/bin/bash
#编译安装python3与pip3
#
set -euo pipefail
#sudo yum -y groupinstall "Development tools"
sudo yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
sudo yum -y install gcc gcc-c++
sudo yum -y install zlib zlib-devel
sudo yum -y install libffi-devel
sudo mkdir /usr/local/python3
#cd ./Python3 && sudo tar -xf Python-3.6.2.tar.xz
cd ./Python3 && sudo tar -xf Python-3.7.0.tar.xz
#cd Python-3.6.2 && sudo ./configure --prefix=/usr/local/python3
cd Python-3.7.0 && sudo ./configure --prefix=/usr/local/python3
sudo make && sudo make install

sudo ln -s /usr/local/python3/bin/python3 /usr/bin/python3
sudo ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
