#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-20 15:00:00
#updated: 2023-04-20 15:00:00

set -e 
source 00_env

# 安装 docker
function install_docker() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    # 需要把 docker-ce.rpm.tar.gz 放到 $ZABBIX_PARCELS 目录下
    mkdir -p /tmp/docker-ce/rpm
    tar -zxvf $ZABBIX_PARCELS/docker-ce.rpm.tar.gz -C /tmp/docker-ce/rpm/

    yum localinstall /tmp/docker-ce/rpm/*.rpm
}

# 启动 docker
function start_docker() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    systemctl start docker
    systemctl restart docker
    systemctl daemon-reload
    systemctl enable docker.service
}

function main() {
    echo -e "$CSTART>07_mysql.sh$CEND"

    echo -e "$CSTART>>install_docker$CEND"
    install_docker

    echo -e "$CSTART>>start_docker$CEND"
    start_docker
}

main
