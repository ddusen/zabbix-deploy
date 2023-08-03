#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-20 20:00:00
#updated: 2023-04-20 20:00:00

set -e 
source 00_env

function remove_old_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND";
        ssh -n $ipaddr "yum remove -y zabbix*" || true
        ssh -n $ipaddr "rm -rf /etc/zabbix*" || true
        ssh -n $ipaddr "rm -rf /var/log/zabbix*" || true
    done 
}

function install_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do 
        # 不在zabbix server上安装agent
        if [[ "$ipaddr" == "$ServerIP" ]]; then
            continue
        fi
        echo -e "$CSTART>>>>$ipaddr$CEND";
        system_version=$(ssh -n $ipaddr "cat /etc/centos-release | sed 's/ //g'")
        echo -e "$CSTART>>>>$ipaddr>$system_version$CEND"

        if [[ "$system_version" == RockyLinuxrelease8* ]]; then
            scp rpms/rocky8/pcre2-10.32-3.el8.x86_64.rpm $ipaddr:/tmp/
            scp rpms/rocky8/pcre2-devel-10.32-3.el8_6.x86_64.rpm $ipaddr:/tmp/
            scp rpms/rocky8/zabbix-agent2-6.4.2-release1.el8.x86_64.rpm $ipaddr:/tmp/

            ssh -n $ipaddr "rpm -Uvh /tmp/pcre2-10.32-3.el8.x86_64.rpm" || true
            ssh -n $ipaddr "rpm -Uvh /tmp/pcre2-devel-10.32-3.el8_6.x86_64.rpm" || true
            ssh -n $ipaddr "rpm -Uvh /tmp/zabbix-agent2-6.4.2-release1.el8.x86_64.rpm" || true
        elif [[ "$system_version" == CentOSLinuxrelease7* ]]; then
            scp rpms/centos7/pcre2-10.23-2.el7.x86_64.rpm $ipaddr:/tmp/
            scp rpms/centos7/zabbix-agent2-6.4.2-release1.el7.x86_64.rpm $ipaddr:/tmp/

            ssh -n $ipaddr "rpm -Uvh /tmp/pcre2-10.23-2.el7.x86_64.rpm" || true
            ssh -n $ipaddr "rpm -Uvh /tmp/zabbix-agent2-6.4.2-release1.el7.x86_64.rpm" || true
        elif [[ "$system_version" == CentOSrelease6* ]]; then
            scp rpms/centos6/pcre-7.8-7.el6.x86_64.rpm $ipaddr:/tmp/
            scp rpms/centos6/zabbix-agent2-6.4.2-release3.el6.x86_64.rpm $ipaddr:/tmp/

            ssh -n $ipaddr "rpm -Uvh /tmp/pcre-7.8-7.el6.x86_64.rpm" || true
            ssh -n $ipaddr "rpm -Uvh /tmp/zabbix-agent2-6.4.2-release3.el6.x86_64.rpm" || true
        else 
            echo "系统版本[$system_version]超出脚本处理范围" && false
        fi
    done
}

function config_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do 
        # 不在zabbix server上安装agent
        if [[ "$ipaddr" == "$ServerIP" ]]; then
            continue
        fi
        echo -e "$CSTART>>>>$ipaddr$CEND";
        scp config/agent2 $ipaddr:/tmp/
        ssh -n $ipaddr "mkdir -p /etc/zabbix"
        ssh -n $ipaddr "cp /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.bak" || true
        ssh -n $ipaddr "cp /tmp/agent2 /etc/zabbix/zabbix_agent2.conf"
        ssh -n $ipaddr "sed -i 's/ZabbixServerIP/$ServerIP/g' /etc/zabbix/zabbix_agent2.conf"
        ssh -n $ipaddr 'sed -i "s/ZabbixClentHostname/$(hostname)/g" /etc/zabbix/zabbix_agent2.conf'
    done
}

function start_agent() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do 
        # 不在zabbix server上安装agent
        if [[ "$ipaddr" == "$ServerIP" ]]; then
            continue
        fi
        echo -e "$CSTART>>>>$ipaddr$CEND";
        system_version=$(ssh -n $ipaddr "cat /etc/centos-release | sed 's/ //g'")
        echo -e "$CSTART>>>>$ipaddr>$system_version$CEND"
        if [[ "$system_version" == CentOSrelease6* ]]; then
            ssh -n $ipaddr "service zabbix-agent2 start" || true
            ssh -n $ipaddr "service zabbix-agent2 restart" || true
            ssh -n $ipaddr "chkconfig --level 35 zabbix-agent2 on" || true
        else 
            ssh -n $ipaddr "systemctl start zabbix-agent2" || true
            ssh -n $ipaddr "systemctl restart zabbix-agent2" || true
            ssh -n $ipaddr "systemctl enable zabbix-agent2" || true
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
