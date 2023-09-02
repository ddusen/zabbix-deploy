#!/bin/bash

#author: Sen Du
#email: dusen.me@gmail.com
#created: 2023-04-20 20:00:00
#updated: 2023-04-20 20:00:00

set -e 
source 00_env

function remove_old_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
        ssh -tt -n $ipaddr "rm -rf ~/zabbix*" || true
        ssh -tt -n $ipaddr "yum remove -y zabbix*" || true
        ssh -tt -n $ipaddr "rm -rf /etc/zabbix*" || true
        ssh -tt -n $ipaddr "rm -rf /var/log/zabbix*" || true
    done 
}

function install_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
        system_version=$(ssh -tt -n $ipaddr "cat /etc/centos-release | sed 's/ //g'")
        echo -e "$CSTART>>>>$ipaddr>$system_version$CEND"

        if [[ "$system_version" == RockyLinuxrelease8* ]]; then
            scp rpms/rocky8/pcre2-devel-10.32-3.el8_6.x86_64.rpm $ipaddr:/tmp
            scp rpms/rocky8/pcre2-10.32-3.el8.x86_64.rpm $ipaddr:/tmp
            scp rpms/rocky8/zabbix-agent2-*.el8.x86_64.rpm $ipaddr:/tmp

            ssh -tt -n $ipaddr "rpm -Uvh /tmp/pcre2-devel-10.32-3.el8_6.x86_64.rpm" || true
            ssh -tt -n $ipaddr "rpm -Uvh /tmp/pcre2-10.32-3.el8.x86_64.rpm" || true
            ssh -tt -n $ipaddr "rpm -Uvh /tmp/zabbix-agent2-*.el8.x86_64.rpm" || true
        elif [[ "$system_version" == CentOSLinuxrelease7* ]]; then
            scp rpms/centos7/pcre2-10.23-2.el7.x86_64.rpm $ipaddr:/tmp
            scp rpms/centos7/zabbix-agent2-*.el7.x86_64.rpm $ipaddr:/tmp

            ssh -tt -n $ipaddr "rpm -Uvh /tmp/pcre2-10.23-2.el7.x86_64.rpm" || true
            ssh -tt -n $ipaddr "rpm -Uvh /tmp/zabbix-agent2-*.el7.x86_64.rpm" || true
        elif [[ "$system_version" == CentOSrelease6* ]]; then
            scp rpms/centos6/pcre-7.8-7.el6.x86_64.rpm $ipaddr:/tmp
            scp rpms/centos6/zabbix-agent2-*.el6.x86_64.rpm $ipaddr:/tmp

            ssh -tt -n $ipaddr "rpm -Uvh /tmp/pcre-7.8-7.el6.x86_64.rpm" || true
            ssh -tt -n $ipaddr "rpm -Uvh /tmp/zabbix-agent2-*.el6.x86_64.rpm" || true
        else 
            echo "系统版本[$system_version]超出脚本处理范围"
        fi
    done
}

function config_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
        scp config/agent2 $ipaddr:/tmp/
        ssh -tt -n $ipaddr "mkdir -p /etc/zabbix"
        ssh -tt -n $ipaddr "cp /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.bak" || true
        ssh -tt -n $ipaddr "cp /tmp/agent2 /etc/zabbix/zabbix_agent2.conf"
        ssh -tt -n $ipaddr "sed -i 's/ZabbixServerIP/$ServerIP/g' /etc/zabbix/zabbix_agent2.conf"
    done
}

function start_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
        system_version=$(ssh -tt -n $ipaddr "cat /etc/centos-release | sed 's/ //g'")
        echo -e "$CSTART>>>>$ipaddr>$system_version$CEND"
        if [[ "$system_version" == CentOSrelease6* ]]; then
            ssh -tt -n $ipaddr "service zabbix-agent2 start" || true
            ssh -tt -n $ipaddr "service zabbix-agent2 restart" || true
            ssh -tt -n $ipaddr "chkconfig --level 35 zabbix-agent2 on" || true
        else 
            ssh -tt -n $ipaddr "systemctl start zabbix-agent2" || true
            ssh -tt -n $ipaddr "systemctl restart zabbix-agent2" || true
            ssh -tt -n $ipaddr "systemctl enable zabbix-agent2" || true
        fi
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
