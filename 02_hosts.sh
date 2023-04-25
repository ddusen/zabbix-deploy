#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 11:00:00
#updated: 2023-04-16 11:00:00

set -e 
source 00_env

# 配置当前节点的 hosts
function config_hosts() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    cp config/hosts /etc/hosts
}

# 配置当前节点的 hostname
function config_hostname() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    echo 'hostname=zabbix-server' > /etc/sysconfig/network
}

function main() {
    echo -e "$CSTART>02_hosts.sh$CEND"
    echo -e "$CSTART>>config_hosts$CEND"
    config_hosts

    echo -e "$CSTART>>config_hostname$CEND"
    config_hostname
}

main
