#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-20 20:00:00
#updated: 2023-04-20 20:00:00

set -e 
source 00_env

function remove_old_agent() {
    cat config/vm_info | while read ipaddr name passwd
    do
        # 不在zabbix server上安装agent
        if [[ "$ipaddr" == "$ServerIP" ]]; then
            continue
        fi
        echo -e "$CSTART>>>>$ipaddr$CEND";
        ssh -n $ipaddr "yum remove -y zabbix*" || true
        ssh -n $ipaddr "rm -rf /etc/zabbix*" || true
        ssh -n $ipaddr "rm -rf /var/log/zabbix*" || true
    done 
}

function install_agent() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        # 不在zabbix server上安装agent
        if [[ "$ipaddr" == "$ServerIP" ]]; then
            continue
        fi
        echo -e "$CSTART>>>>$ipaddr$CEND";
        scp rpms/pcre2-10.23-2.el7.x86_64.rpm $ipaddr:/tmp/
        scp rpms/zabbix-agent2-6.4.2-release1.el7.x86_64.rpm $ipaddr:/tmp/

        ssh -n $ipaddr "rpm -Uvh /tmp/pcre2-10.23-2.el7.x86_64.rpm" || true
        ssh -n $ipaddr "rpm -Uvh /tmp/zabbix-agent2-6.4.2-release1.el7.x86_64.rpm" || true
    done
}

function config_agent() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        # 不在zabbix server上安装agent
        if [[ "$ipaddr" == "$ServerIP" ]]; then
            continue
        fi
        echo -e "$CSTART>>>>$ipaddr$CEND";
        scp config/agent $ipaddr:/tmp/
        ssh -n $ipaddr "cp /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.bak"
        ssh -n $ipaddr "cp /tmp/agent /etc/zabbix/zabbix_agent2.conf"
        ssh -n $ipaddr "sed -i "s/ZabbixClentHostname/$(hostname)/g" /etc/zabbix/zabbix_agent2.conf"
    done
}

function start_agent() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        # 不在zabbix server上安装agent
        if [[ "$ipaddr" == "$ServerIP" ]]; then
            continue
        fi
        echo -e "$CSTART>>>>$ipaddr$CEND";
        ssh -n $ipaddr "systemctl restart zabbix-agent2; systemctl enable zabbix-agent2"
    done
}

function main() {
    echo -e "$CSTART>06_zabbix_agent.sh$CEND"

    echo -e "$CSTART>>remove_old_agent$CEND"
    remove_old_agent
    
    echo -e "$CSTART>>install_agent$CEND"
    install_agent

    echo -e "$CSTART>>config_agent$CEND"
    config_agent

    echo -e "$CSTART>>start_agent$CEND"
    start_agent
}

main
