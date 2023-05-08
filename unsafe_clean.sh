#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-18 15:00:00
#updated: 2023-04-18 15:00:00

set -e 
source 00_env

# 避免误操作，添加输入密码步骤
function identification() {
    read -s -p "请输入密码: " pswd
    shapswd=$(echo $pswd | sha1sum | head -c 10)
    if [[ "$shapswd" == "d5b3776603" ]]; then
        echo && true
    else
        echo && false
    fi
}

# 清理所有服务器上的 zabbix 服务
function clean_zabbix_server() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    docker-compose -f docker-compose.yml down
    rm -rf $ServerDataPath/zabbix/fonts
    rm -rf $ServerDataPath/zabbix/db
    rm -rf $ServerDataPath/zabbix/alertscripts
    rm -rf $ServerDataPath/zabbix
}

function main() {
    echo -e "$CSTART>unsafe_clean.sh$CEND"

    echo -e "$CSTART>>identification$CEND"
    identification || true

    echo -e "$CSTART>>clean_zabbix_server$CEND"
    clean_zabbix_server || true
}

main
