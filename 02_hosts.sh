#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 11:00:00
#updated: 2023-04-16 11:00:00

set -e 
source 00_env

# 配置当前节点的 hosts
function config_hosts() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    cp config/hosts /etc/hosts
    sed -i "s/TODO_SERVER_IP/$ServerIP/g" /etc/hosts
}

# 配置当前节点的 hostname
function config_hostname() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    echo "hostname=$ServerHostname" > /etc/sysconfig/network
    echo "$ServerHostname" > /etc/hostname
    hostnamectl set-hostname $ServerHostname
}

function main() {
    echo -e "$CSTART>02_hosts.sh$CEND"
    echo -e "$CSTART>>config_hosts$CEND"
    config_hosts

    echo -e "$CSTART>>config_hostname$CEND"
    config_hostname
}

main
