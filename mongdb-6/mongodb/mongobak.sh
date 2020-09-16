#!/bin/bash
FLODER="/home/mongobak"
DATE=$(date '+%Y-%m-%d')
if [ ! -d "$FLODER" ];then
    mkdir -p "$FLODER"
fi
find "$FLODER" -mtime +10 |xargs rm -rf
cd /usr/local/mongodb
./bin/mongodump -h 192.168.1.1 --port=37018 -u root -p YiZhu2018everybim! --oplog --gzip -o "$FLODER"/mongodb-$DATE
