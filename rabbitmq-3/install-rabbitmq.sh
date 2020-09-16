#!/bin/bash
#安装rabbitmq
#需要wget命令可用
#
set -euo pipefail
echo -e "##### RabbitMQ安装开始，请仔细输入一些变量 ##### \n"
read -p "输入本机IP，比如192.168.1.55: " IPADDR
read -p "确认以上输入正确吗？yes or no: " JUDGE
if [ $JUDGE == "yes" ];then
  echo -e "ip is $IPADDR \n"
else
  exit 1
fi
[ -z $IPADDR ] && exit 1
echo -e "##### RabbitMQ开始安装 ##### \n"
##wget --content-disposition https://packagecloud.io/rabbitmq/erlang/packages/el/7/erlang-20.3-1.el7.centos.x86_64.rpm/download.rpm
sudo yum -y localinstall ./software/socat-1.7.3.2-2.el7.x86_64.rpm
sudo yum -y localinstall ./software/erlang-20.3-1.el7.centos.x86_64.rpm
##wget https://dl.bintray.com/rabbitmq/all/rabbitmq-server/3.7.5/rabbitmq-server-3.7.5-1.el7.noarch.rpm
sudo yum -y localinstall ./software/rabbitmq-server-3.7.5-1.el7.noarch.rpm
sudo sed -ri s?IPADDR?$IPADDR?g ./rabbitmq/rabbitmq.config
sudo cp ./rabbitmq/rabbitmq.config /etc/rabbitmq/rabbitmq.config
HOSTNAME=`hostname`
sudo sed -ri s?HOSTNAME?$HOSTNAME?g ./rabbitmq/rabbitmq-env.conf
sudo cp ./rabbitmq/rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf
sudo systemctl enable rabbitmq-server
sudo sed -ri s?\#\ LimitNOFILE\=16384?LimitNOFILE\=30000? /usr/lib/systemd/system/rabbitmq-server.service
sudo systemctl daemon-reload
sudo systemctl start rabbitmq-server
IS_SUCCESS=`systemctl status rabbitmq-server | grep Active | grep -o running`
if [ $IS_SUCCESS == "running" ];then
	echo -e "##### RabbitMQ安装成功 ##### \n"
else
	echo -e "##### RabbitMQ启动失败，请检查 ##### \n"
	exit 1
fi
sudo rabbitmq-plugins enable rabbitmq_management
sudo rabbitmqctl change_password guest YiZhu2018everybim!
sudo yum install -y wget
sudo wget http://$IPADDR:15672/cli/rabbitmqadmin
sudo chmod a+x rabbitmqadmin
sudo mv rabbitmqadmin /usr/bin/rabbitmqadmin
echo -e "##### RabbitMQ开始导入配置 ##### \n"
sudo rabbitmqadmin -u guest -p YiZhu2018everybim! -q import  --vhost=/ ./rabbitmq/rabbit_localhost.json
if [ $? -eq 0 ];then
	echo -e "##### RabbitMQ配置导入成功 ##### \n"
else
	echo -e "##### RabbitMQ配置导入失败，请检查 ##### \n"
	exit 1
fi