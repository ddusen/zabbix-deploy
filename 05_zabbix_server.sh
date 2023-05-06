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
    mkdir -p $ServerDataPath/zabbix
    mkdir -p $ServerDataPath/zabbix/fonts
    mkdir -p $ServerDataPath/zabbix/db
    mkdir -p $ServerDataPath/zabbix/alertscripts
    mkdir -p $ServerDataPath/zabbix/share

    chmod -R 777 $ServerDataPath/zabbix/share
    
    tar -zxvf $ZABBIX_PARCELS/msty.ttf.tar.gz -C /tmp/
    mv /tmp/msty.ttf $ServerDataPath/zabbix/fonts/DejaVuSans.ttf
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
