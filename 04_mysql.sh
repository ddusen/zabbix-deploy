#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 15:00:00
#updated: 2023-04-16 15:00:00

set -e 
source 00_env

DATA="/data/mysql"

# 安装 mysql8
function install_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    mkdir -p /tmp/mysql8/rpm
    tar -zxvf $ZABBIX_PARCELS/mysql8.0.33.tar.gz -C /tmp/mysql8/rpm
    yum localinstall -y /tmp/mysql8/rpm/*.rpm || true # 忽略报错
}

# 配置 mysql8
function config_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    mkdir -p $DATA
    chown -R mysql $DATA
    chgrp -R mysql $DATA
    chmod 755 $DATA
    cp /etc/my.cnf /etc/my.cnf.bak
    cp config/mysql /etc/my.cnf
}

# 重启 mysql8
function restart_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    systemctl restart mysqld
    systemctl enable --now mysqld
}

# 初始化 mysql 数据
function init_mysql() {

}

function main() {
    echo -e "$CSTART>07_mysql.sh$CEND"

    echo -e "$CSTART>>install_mysql$CEND"
    install_mysql
}

main
