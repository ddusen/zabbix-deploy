#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-20 20:00:00
#updated: 2023-04-20 20:00:00

set -e 
source 00_env

# config zabbix
function config_zabbix() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    mkdir -p /data/zabbix
    mkdir -p /data/zabbix/fonts
    mkdir -p /data/zabbix/db
    mkdir -p /data/zabbix/alertscripts

    tar -zxvf $ZABBIX_PARCELS/msty.ttf.tar.gz -C /tmp/
    mv /tmp/msty.ttf /data/zabbix/fonts/DejaVuSans.ttf
}

function start_zabbix() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    docker-compose -f docker-compose.yml up -d
}

function main() {
    echo -e "$CSTART>05_zabbix.sh$CEND"

    echo -e "$CSTART>>config_zabbix$CEND"
    config_zabbix

    echo -e "$CSTART>>start_zabbix$CEND"
    start_zabbix
}

main
