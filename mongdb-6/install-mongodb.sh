#!/bin/bash
#mongodb 安装脚本
#支持安装副本集和单节点
#单节点数据库端口37017
#副本集PRIMARY37017、SECONDARY37018、ARBITER37019
#
set -euo pipefail

PRIPORT="37017"
SECPORT="37018"
ARBPORT="37019"
MONGOBASE="/usr/local/mongodb"
PRIDATA="mongodbp"
SECDATA="mongodbs"
ARBDATA="mongodba"

function initmongo(){
    cp ./mongodb/mongo.conf $1
    sed -ri s?\/MONGODIR?$DATADIR?g $1      ##替换数据库存储目录
    sed -ri s?DATABASE?$4?g $1              ##替换数据库存储目录
    sed -ri s?IPADDR?$IPADDR?g $1           ##替换数据库绑定ip
    sed -ri s?PORT?$2?g $1                  ##替换数据库绑定端口
    sed -ri s?MONGOBASE?$MONGOBASE?g $1     ##替换keyfile所在目录
    sed -ri s?OPLOGSIZE?$3?g $1             ##替换oplog大小设置
    cp $1  $MONGOBASE/conf/$1
}
function installmongo(){
    if [ -d $MONGOBASE ];then
        echo -e "$MONGOBASE 目录已经存在，请修改脚本开头MONGOBASE变量"
        exit 1
    fi
    if [ -d $DATADIR/$1 ];then
        echo -e "$DATADIR/$1 目录已经存在，请修改脚本开头$1变量"
        exit 1
    fi
    tar -xf ./software/mongodb-linux-x86_64-rhel70-3.6.9.tgz
    mv mongodb-linux-x86_64-rhel70-3.6.9 $MONGOBASE
    mkdir -p $MONGOBASE/conf
    mkdir -p $DATADIR/$1/dbm
    mkdir -p $DATADIR/$1/logs
}

echo -e "##### mongodb安装开始，请仔细输入一些变量 ##### \n"
read -p "输入本机IP，比如192.168.1.55: " IPADDR
read -p "输入mongodb数据库目录，比如/home、/data：" DATADIR
read -p "确认以上输入正确吗？yes or no: " JUDGE
if [ $JUDGE == "yes" ];then
  echo -e "ip is $IPADDR, mongo root directory is $DATADIR \n"
else
  exit 1
fi
[ -z $IPADDR ] || [ -z $DATADIR ] && exit 1 
echo -e "##### mongodb开始安装 ##### \n"
read -p "本次部署是副本集吗？yes or no: " IS_REPLICA
if [ $IS_REPLICA == "yes" ];then
    read -p "请输入副本集节点类型,PRI、SEC、ARB: " IS_PRIMARY
    read -p "请输入OPLOG大小，单位为MB: (数据存储分区的5%): " OPLOGSIZE
    case "$IS_PRIMARY" in
        "PRI")
                    priconf="mongom.conf"
                    installmongo $PRIDATA
                    openssl rand -base64 756 > $MONGOBASE/conf/keyfile ##生成keyfile
                    chmod 400 $MONGOBASE/conf/keyfile  ##更改keyfile访问权限
                    initmongo $priconf $PRIPORT $OPLOGSIZE $PRIDATA
                    $MONGOBASE/bin/mongod -f $MONGOBASE/conf/$priconf ##启动数据库
                    sed -ri s?PORT?$PRIPORT?g ./mongodb/addAccount.js 
                    sed -ri s?PORT?$PRIPORT?g ./mongodb/addRoot.js 
                    $MONGOBASE/bin/mongo 127.0.0.1:$PRIPORT/test --eval "printjson(rs.initiate())" ##初始化副本集
                    sleep 5
                    $MONGOBASE/bin/mongo 127.0.0.1:$PRIPORT/admin ./mongodb/addRoot.js ##创建root管理员账号
                    $MONGOBASE/bin/mongo 127.0.0.1:$PRIPORT/admin ./mongodb/addAccount.js    ##创建everybim账号和数据库                   
                    ;;
        "SEC")
                    secconf="mongob.conf"
                    installmongo $SECDATA
                    while [ ! -f $MONGOBASE/conf/keyfile ]
                    do
                        echo -e "请拷贝主节点keyfile到 $MONGOBASE/conf/keyfile\n"
                        echo -e "请确认keyfile读写权限为400\n"
                        read -p "是否完成上述操作？yes or no: " JUDGE
                        if [ $JUDGE == "yes" ];then
                            echo -e "确认完成\n"
                        fi
                    done
                    initmongo $secconf $SECPORT $OPLOGSIZE $SECDATA
                    $MONGOBASE/bin/mongod -f $MONGOBASE/conf/$secconf
                    ;;
        "ARB")
                    arbconf="mongoa.conf"
                    if [ ! -d $MONGOBASE ];then
                        echo -e "$MONGOBASE 目录不存在"
                        exit 1
                    fi
                    if [ -d $DATADIR/$ARBDATA ];then
                        echo -e "$DATADIR/$ARBDATA 目录已经存在，请更换MongoDB数据存储目录"
                        exit 1
                    fi
                    mkdir -p $DATADIR/$ARBDATA/dbm
                    mkdir -p $DATADIR/$ARBDATA/logs
                    initmongo $arbconf $ARBPORT $OPLOGSIZE $ARBDATA
                    $MONGOBASE/bin/mongod -f $MONGOBASE/conf/$arbconf
                    ;;
        *)
                    echo -e "输入错误，终止部署 \n"
                    exit 1
                    ;;
    esac

else
    echo -e "##### mongodb单实例部署开始 ##### \n"
    installmongo $PRIDATA
    initmongo mongom.conf $PRIPORT 10240 $PRIDATA
    sed -ri s?authorization?\#authorization?g $MONGOBASE/conf/mongom.conf
    sed -ri s?clusterAuthMode?\#clusterAuthMode?g $MONGOBASE/conf/mongom.conf
    sed -ri s?keyFile:?\#keyFile:?g $MONGOBASE/conf/mongom.conf
    sed -ri s?replSetName?\#replSetName?g $MONGOBASE/conf/mongom.conf
    $MONGOBASE/bin/mongod -f $MONGOBASE/conf/mongom.conf
    sed -ri s?IPADDR?$IPADDR?g ./mongodb/addAccount_v1.js
    sed -ri s?PORT?$PRIPORT?g ./mongodb/addAccount_v1.js
    $MONGOBASE/bin/mongo $IPADDR:$PRIPORT/admin ./mongodb/addAccount_v1.js  ##创建账号和数据库
    #kill -9 `ps -ef | grep mongod | grep -v grep |awk '{print$2}'`
    #sed -ri s?#authorization:\ enabled?authorization:\ enabled?g $MONGOBASE/bin/mongom.conf
    #$MONGOBASE/bin/mongod -f $MONGOBASE/conf/mongom.conf
fi

#/usr/local/mongodb/bin/mongo $IPADDR:37017/admin addAccount.js
#db.createUser({user:"root",pwd:"YiZhu2018everybim!",roles:[{role: "root",db:"admin"}]})
#db.createUser({user:"everybim",pwd:"YiZhu2018everybim!",roles:[{role: "readWriteAnyDatabase",db:"admin"}]})
#db.createUser({user:"everybim",pwd:"YiZhu2018everybim!",roles:[{role: "readWrite",db:"sessiondb"}]})
#
