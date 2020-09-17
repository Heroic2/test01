read -p 请输入主机名如"node01":   HOSTNAME
hostnamectl --static set-hostname $HOSTNAME
##时间同步
timedatectl set-timezone Asia/Shanghai;
echo "*/30 * * * * /usr/sbin/ntpdate us.pool.ntp.org" >> /var/spool/cron/root;
##调整打开文件数限制
echo "fs.file-max=655350" >> /etc/sysctl.conf;
echo "
*               soft            nofile                  65535
*               hard            nofile                  65535
*               soft            nproc                   65535
*               hard            nproc                   65535   " >> /etc/security/limits.conf;
chmod a+x /etc/rc.d/rc.local;
mkdir -p /etc/systemd/system/rc-local.service.d;
## 有docker服务的节点按下面添加
cat << 'EOF' >> /etc/systemd/system/rc-local.service.d/override.conf
[Unit]
After=network.target docker.service
Wants=docker.service


[Service]
LimitNOFILE=30000
LimitNPROC=30000
EOF
yum -y install lrzsz vim wget unzip epel-release ntpdate sysstat rsync;
yum -y install bind-utils net-tools yum-utils psmisc telnet-server xinetd;
yum -y install gcc make gcc-c++ openssl openssl-devel;
