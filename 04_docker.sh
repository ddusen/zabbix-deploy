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

    yum localinstall -y /tmp/docker-ce/rpm/*.rpm || true
}

# 启动 docker
function start_docker() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    systemctl restart docker
    systemctl daemon-reload
    systemctl enable docker.service
}

# 安装 docker compose
function install_docker_compose() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    tar -zxvf $ZABBIX_PARCELS/docker-compose.tar.gz -C /usr/local/bin/
    chmod +x /usr/local/bin/docker-compose
}

# load docker images
function load_docker_images() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    tar -zxvf /opt/zabbix-parcels/mysql.8.0.33.tar.gz -C /tmp/
    tar -zxvf /opt/zabbix-parcels/zabbix-web-nginx-mysql.6.0.16-centos.tar.gz -C /tmp/
    tar -zxvf /opt/zabbix-parcels/zabbix-server-mysql.6.0.16-centos.tar.gz -C /tmp/
    tar -zxvf /opt/zabbix-parcels/zabbix-java-gateway.6.0.16-centos.tar.gz -C /tmp/

    docker load -i /tmp/mysql.8.0.33.tar
    docker load -i /tmp/zabbix-web-nginx-mysql.6.0.16-centos.tar
    docker load -i /tmp/zabbix-server-mysql.6.0.16-centos.tar
    docker load -i /tmp/zabbix-java-gateway.6.0.16-centos.tar
}

function main() {
    echo -e "$CSTART>04_docker.sh$CEND"

    echo -e "$CSTART>>install_docker$CEND"
    install_docker

    echo -e "$CSTART>>start_docker$CEND"
    start_docker

    echo -e "$CSTART>>install_docker_compose$CEND"
    install_docker_compose

    echo -e "$CSTART>>load_docker_images$CEND"
    load_docker_images
}

main
