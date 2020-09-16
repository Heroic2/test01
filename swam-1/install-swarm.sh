#!/bin/bash
# 
# 安装Docker、Docker-compose、初始化Swarm
# 
# 
set -euo pipefail

echo -e "##### Swarm安装开始，请仔细输入一些变量 ##### \n"
read -p "输入本机内网IP，比如192.168.1.55: " IPADDR
read -p "输入docker镜像目录，比如/home、/data：" DATADIR
read -p "输入docker0网络地址，比如10.10.0.1：" DOCKER0
read -p "确认以上输入正确吗？yes or no: " JUDGE
if [ $JUDGE == "yes" ];then
  echo -e "ip is $IPADDR, Docker Container directory is $DATADIR/docker \n"
else
  exit 1
fi
[ -z $IPADDR ] || [ -z $DATADIR ] && exit 1

echo -e "##### Docker安装开始 ##### \n"
sudo yum -y install yum-utils device-mapper-persistent-data lvm2
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo ##阿里云源加速
sudo yum -y install docker-ce-19.03.4
sudo mkdir -p /etc/docker
sudo sed -ri s?\/DATADIR?$DATADIR?g ./swarm/daemon.json  #替换数据库目录
sudo sed -ri s?DOCKER0?$DOCKER0?g ./swarm/daemon.json  #替换docker0地址 
sudo cp ./swarm/daemon.json /etc/docker/daemon.json
sudo systemctl enable docker
sudo systemctl start docker
IS_SUCCESS=`sudo systemctl is-active docker`
if [ $IS_SUCCESS == "active" ];then
	echo -e "##### Docker安装成功 ##### \n"
else
	echo -e "##### Docker启动失败，请检查 ##### \n"
	exit 1
fi

#echo -e "##### Docker-Compose安装开始 ##### \n"
#curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
#chmod a+x /usr/local/bin/docker-compose
#docker-compose --version
#if [ $? -eq 0 ];then
#	echo -e "##### Docker-Compose安装成功 ##### \n"
#else
#	echo -e "##### Docker-Compose安装失败，请检查 ##### \n"
#	exit 1
#fi

echo -e "##### Swarm初始化开始 ##### \n"
read -p "请输入docker_gwbridge子网地址, eg: 10.20.0.0/16 : " SUBNET
read -p "请输入docker_gwbridge网关地址, eg: 10.20.0.1 : " GATEWAY
sudo docker network create --subnet $SUBNET --gateway $GATEWAY -o com.docker.network.bridge.enable_icc=false -o com.docker.network.bridge.name=docker_gwbridge -o com.docker.network.bridge.enable_ip_masquerade=true docker_gwbridge
read -p "这台机器是Swarm Master吗? yes or no : " ISMASTER
if [ $ISMASTER == "yes" ]; then
  sudo touch swarm.info && sudo chmod a+w swarm.info 
  sudo docker swarm init --advertise-addr $IPADDR > swarm.info 2>&1 
  echo -e "##### Swarm集群初始化成功 ##### \n"
  read -p "Swarm集群是否还有Worker节点? yes or no : " HasWorker
  if [ $HasWorker == "yes" ]; then
  	echo -e "##### 请在Worker加入集群之后执行: docker node update --label-add role=largeFile nodex ##### \n"
  	echo -e "##### nodex替换为Worker节点的HOSTNAME ##### \n"
  else
  	MASTERNAME=`sudo hostname`
  	sudo docker node update --label-add role=largeFile $MASTERNAME
    [ ! -d /home/uploadtmp ] && sudo mkdir /home/uploadtmp
  fi
else
  echo -e "##### 请手动执行docker swarm join 命令 ##### \n"
  [ ! -d /home/uploadtmp ] && sudo mkdir /home/uploadtmp
  echo -e "##### 请在master上执行: docker node update --label-add role=largeFile nodex ##### \n"
  echo -e "##### nodex替换为Worker节点的HOSTNAME ##### \n"
fi
