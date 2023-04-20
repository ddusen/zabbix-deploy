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

function main() {
    echo -e "$CSTART>03_init.sh$CEND"

    echo -e "$CSTART>>install_base$CEND"
    install_base

    echo -e "$CSTART>>stop_hugepage$CEND"
    disable_hugepage

    echo -e "$CSTART>>disable_selinux$CEND"
    disable_selinux

    echo -e "$CSTART>>config_ssh$CEND"
    config_ssh

    echo -e "$CSTART>>config_network$CEND"
    config_network || true # 忽略报错
}

main
