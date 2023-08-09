#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-20 20:00:00
#updated: 2023-04-20 20:00:00

set -e 
source 00_env

# config zabbix
function config_server() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    mkdir -p $ServerDataPath/zabbix
    mkdir -p $ServerDataPath/zabbix/conf
    mkdir -p $ServerDataPath/zabbix/fonts
    mkdir -p $ServerDataPath/zabbix/db
    mkdir -p $ServerDataPath/zabbix/alertscripts
    mkdir -p $ServerDataPath/zabbix/share
    mkdir -p $ServerDataPath/grafana/data
    mkdir -p $ServerDataPath/grafana/datasources
    mkdir -p $ServerDataPath/grafana/plugins

    chmod -R 777 $ServerDataPath/zabbix/share
    
    cp config/server $ServerDataPath/zabbix/conf/zabbix_server.conf

    tar -zxvf $ZABBIX_PARCELS/msty.ttf.tar.gz -C /tmp/
    mv /tmp/msty.ttf $ServerDataPath/zabbix/fonts/DejaVuSans.ttf

    tar -zxvf $ZABBIX_PARCELS/alexanderzobnin-zabbix-app.tar.gz -C $ServerDataPath/grafana/plugins/
}

function start_server() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
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
