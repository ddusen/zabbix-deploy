#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 10:00:00
#updated: 2023-04-16 10:00:00

set -e 
source 00_env

# 安装一些基础软件，便于后续操作
function install_base() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr$CEND"
        scp rpms/*.rpm $ipaddr:/tmp/
        ssh -n $ipaddr "rpm -Uvh /tmp/*.rpm" || true
    done
}

# 备份一些配置文件
function backup_configs() {
    cat config/vm_info | while read ipaddr name passwd
    do 
        echo -e "$CSTART>>>>$ipaddr$CEND";
        ssh -n $ipaddr "mkdir -p /opt/backup_sys_configs;";
        ssh -n $ipaddr "cp /etc/security/limits.conf /opt/backup_sys_configs;";
        ssh -n $ipaddr "cp /etc/security/limits.d/20-nproc.conf /opt/backup_sys_configs;";
        ssh -n $ipaddr "cp /etc/sysctl.conf /opt/backup_sys_configs;";
        ssh -n $ipaddr "cp /etc/ssh/sshd_config /opt/backup_sys_configs";
    done
}

# 禁用 hugepage
function disable_hugepage() {
    cat config/vm_info | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND"
        ssh -n $ipaddr "grubby --update-kernel=ALL --args='transparent_hugepage=never'"; 
        ssh -n $ipaddr "sed -i '/^#RemoveIPC=no/cRemoveIPC=no' /etc/systemd/logind.conf; systemctl restart systemd-logind.service";
    done
}

# 关闭 selinux
function disable_selinux() {
    cat config/vm_info | while read ipaddr name passwd
    do
        ssh -n $ipaddr "sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config;"; 
    done
}

# 配置ssh
function config_ssh() {
    cat config/vm_info | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND"
        ssh -n $ipaddr "sed -i '/^#UseDNS/cUseDNS no' /etc/ssh/sshd_config;";
        ssh -n $ipaddr "sed -i '/^GSSAPIAuthentication/cGSSAPIAuthentication no' /etc/ssh/sshd_config;";
        ssh -n $ipaddr "sed -i '/^GSSAPICleanupCredentials/cGSSAPICleanupCredentials no' /etc/ssh/sshd_config;";
        ssh -n $ipaddr "sed -i '/^#MaxStartups/cMaxStartups 10000:30:20000' /etc/ssh/sshd_config;";
    done
}

# 配置网络策略
function config_network() {
    cat config/vm_info | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND"
        ssh -n $ipaddr "chkconfig iptables off; chkconfig ip6tables off; chkconfig postfix off;";
        ssh -n $ipaddr "systemctl disable postfix; systemctl disable libvirtd; systemctl disable firewalld;";
        ssh -n $ipaddr "systemctl stop postfix; systemctl stop libvirtd; systemctl stop firewalld;";
    done
}

# 配置一些插件 jars
function config_jars() {
    cat config/vm_info | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND"
        ssh -n $ipaddr "mkdir -p /usr/share/java"
        ssh -n $ipaddr "wget -O /tmp/mysql-connector-java.jar.tar.gz $HTTPD_SERVER/others/mysql-connector-java.jar.tar.gz"
        ssh -n $ipaddr "tar -zxvf /tmp/mysql-connector-java.jar.tar.gz -C /usr/share/java"

        ssh -n $ipaddr "mkdir -p /usr/share/hive"
        ssh -n $ipaddr "wget -O /tmp/commons-httpclient-3.1.jar.tar.gz $HTTPD_SERVER/others/commons-httpclient-3.1.jar.tar.gz"
        ssh -n $ipaddr "wget -O /tmp/elasticsearch-hadoop-6.3.0.jar.tar.gz $HTTPD_SERVER/others/elasticsearch-hadoop-6.3.0.jar.tar.gz"
        ssh -n $ipaddr "tar -zxvf /tmp/commons-httpclient-3.1.jar.tar.gz -C /usr/share/hive"
        ssh -n $ipaddr "tar -zxvf /tmp/elasticsearch-hadoop-6.3.0.jar.tar.gz -C /usr/share/hive"
    done
}

function main() {
    echo -e "$CSTART>03_init.sh$CEND"

    echo -e "$CSTART>>install_base$CEND"
    install_base

    echo -e "$CSTART>>backup_configs$CEND"
    backup_configs

    echo -e "$CSTART>>stop_hugepage$CEND"
    disable_hugepage

    echo -e "$CSTART>>disable_selinux$CEND"
    disable_selinux

    echo -e "$CSTART>>config_ssh$CEND"
    config_ssh

    echo -e "$CSTART>>config_network$CEND"
    config_network || true # 忽略报错

    echo -e "$CSTART>>config_jars$CEND"
    config_jars
}

main
