#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 15:00:00
#updated: 2023-04-16 15:00:00

set -e 
source 00_env

# 安装 mysql8
function install_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    mkdir -p /tmp/mysql8/rpm
    tar -zxvf $ZABBIX_PARCELS/mysql8.0.33.tar.gz -C /tmp/mysql8/rpm
    yum localinstall -y /tmp/mysql8/rpm/*.rpm || true # 忽略报错
}

function main() {
    echo -e "$CSTART>07_mysql.sh$CEND"

    echo -e "$CSTART>>install_mysql$CEND"
    install_mysql
}

main
