#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-18 15:00:00
#updated: 2023-04-18 15:00:00

set -e 
source 00_env

# 避免误操作，添加输入密码步骤
function identification() {
    read -s -p "请输入密码(该操作有风险，请确保清醒): " pswd
    shapswd=$(echo $pswd | sha1sum | head -c 10)
    if [[ "$shapswd" == "e6283c043a" ]]; then
        echo && true
    else
        echo -e "\033[33m密码错误，程序终止！\033[0m"
        echo && false
    fi
}

# 清理 zabbix server
function clean_zabbix_server() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    docker-compose -f docker-compose.yml down
    rm -rf $ServerDataPath/zabbix/fonts
    rm -rf $ServerDataPath/zabbix/db
    rm -rf $ServerDataPath/zabbix/alertscripts
    rm -rf $ServerDataPath/zabbix
}

# 清理 zabbix agent
function clean_zabbix_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND";
        ssh -n $ipaddr "yum remove -y zabbix*" || true
        ssh -n $ipaddr "rm -rf /etc/zabbix*" || true
        ssh -n $ipaddr "rm -rf /var/log/zabbix*" || true
    done 
}

function main() {
    echo -e "$CSTART>unsafe_clean.sh$CEND"

    echo -e "$CSTART>>identification$CEND"
    identification || true

    echo -e "$CSTART>>clean_zabbix_server$CEND"
    clean_zabbix_server || true

    echo -e "$CSTART>>clean_zabbix_agent$CEND"
    clean_zabbix_agent || true
}

main
