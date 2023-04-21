#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-20 20:00:00
#updated: 2023-04-20 20:00:00

set -e 
source 00_env


function install_agent() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr$CEND";
        scp rpms/pcre2-10.23-2.el7.x86_64.rpm $ipaddr:/tmp/
        scp rpms/zabbix-agent-6.4.1-release1.el7.x86_64.rpm $ipaddr:/tmp/
        ssh -n $ipaddr "rmp -Uvh /tmp/pcre2-10.23-2.el7.x86_64.rpm" || true
        ssh -n $ipaddr "rmp -Uvh /tmp/zabbix-agent-6.4.1-release1.el7.x86_64.rpm" || true
    done
}

function config_agent() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr$CEND";
        scp config/agent $ipaddr:/tmp/
        ssh -n $ipaddr "cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.bak"
        ssh -n $ipaddr "cp /etc/agent /etc/zabbix/zabbix_agentd.conf"
    done
}

function start_agent() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr$CEND";
        ssh -n $ipaddr "systemctl restart zabbix-agent; systemctl enable zabbix-agent"
    done
}

function main() {
    echo -e "$CSTART>06_zabbix_agent.sh$CEND"

    echo -e "$CSTART>>install_agent$CEND"
    install_agent

    echo -e "$CSTART>>config_agent$CEND"
    config_agent

    echo -e "$CSTART>>start_agent$CEND"
    start_agent
}

main
