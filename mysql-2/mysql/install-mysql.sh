#!/bin/bash
#
#安装mysql5.7
#selinux必须disabled
#依赖文件：my.cnf workflow.sql mysql80-community-release-el7-1.noarch.rpm
#
set -euo pipefail

#若selinux未禁用，脚本自动退出
SELINUX_STATUS=`getenforce`
if [ $SELINUX_STATUS == 'Enforcing' ];then
	echo -e "##### SELINUX未禁用，请检查! ##### \n"
	exit 1
fi

echo -e "##### mysql安装开始，请仔细输入一些变量 ##### \n"
read -p "输入本机IP，比如192.168.1.55: " IPADDR
read -p "输入mysql数据库目录，比如/home、/data：" DATADIR
read -p "确认以上输入正确吗？yes or no: " JUDGE
if [ $JUDGE == "yes" ];then
  echo -e "ip is $IPADDR, mysql directory is $DATADIR/mysql\n"
else
  exit 1
fi
[ -z $IPADDR ] || [ -z $DATADIR ] && exit 1
echo -e "##### mysql开始安装 ##### \n"
sudo yum -y install yum-utils
sudo yum -y localinstall ./software/mysql80-community-release-el7-1.noarch.rpm
sudo yum-config-manager --disable mysql80-community
sudo yum-config-manager --enable mysql57-community
sudo yum -y install mysql-community-server
sudo systemctl enable mysqld.service
sudo mkdir -p $DATADIR/mysql/data
sudo mkdir -p $DATADIR/mysql/logs
sudo chown -R mysql.mysql $DATADIR/mysql
sudo sed -ri s?\/MYSQLDIR?$DATADIR?g ./mysql/my.cnf
sudo sed -ri s?IPADDR?$IPADDR?g ./mysql/my.cnf
sudo mv /etc/my.cnf /etc/my.cnf.bak
sudo cp ./mysql/my.cnf /etc/my.cnf
sudo systemctl start mysqld.service
tmppass=`sudo grep 'temporary password' $DATADIR/mysql/logs/mysql-error.log | awk -F 'root@localhost: ' '{print $2}'`
sudo mysqladmin -uroot -p$tmppass password YiZhu2018admin!
sudo mysql -uroot -pYiZhu2018admin! < ./mysql/workflow.sql


##root YiZhu2018admin!
##everybim YiZhu2018everybim!
# 修改root默认密码 ALTER USER 'root'@'localhost' IDENTIFIED BY 'YiZhu2018admin!'; 
# 创建workflow数据库 CREATE DATABASE IF NOT EXISTS workflowdb  DEFAULT CHARSET utf8;
# 创建everybim用户 CREATE USER 'everybim'@'%' IDENTIFIED BY 'YiZhu2018everybim!'; 
# 授权             GRANT ALL PRIVILEGES ON workflowdb.* TO 'everybim'@'%';