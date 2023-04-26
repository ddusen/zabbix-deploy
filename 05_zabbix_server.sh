#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-20 20:00:00
#updated: 2023-04-20 20:00:00

set -e 
source 00_env

# config zabbix
function config_server() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    mkdir -p /data/zabbix
    mkdir -p /data/zabbix/fonts
    mkdir -p /data/zabbix/db
    mkdir -p /data/zabbix/alertscripts
    mkdir -p /data/zabbix/share

    chmod -R 777 /data/zabbix/share
    
    tar -zxvf $ZABBIX_PARCELS/msty.ttf.tar.gz -C /tmp/
    mv /tmp/msty.ttf /data/zabbix/fonts/DejaVuSans.ttf
}

function start_server() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    docker-compose -f docker-compose.yml up -d
}

function main() {
    echo -e "$CSTART>05_zabbix_server.sh$CEND"

    echo -e "$CSTART>>config_server$CEND"
    config_server

    echo -e "$CSTART>>start_server$CEND"
    start_server
}

main
