#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 10:00:00
#updated: 2023-04-16 10:00:00

set -e 
source 00_env

# 安装一些基础软件，便于后续操作
function install_base() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    cp rpms/*.rpm /tmp/
    rpm -Uvh /tmp/*.rpm
}

# 禁用 hugepage
function disable_hugepage() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    grubby --update-kernel=ALL --args='transparent_hugepage=never'
    sed -i '/^#RemoveIPC=no/cRemoveIPC=no' /etc/systemd/logind.conf; systemctl restart systemd-logind.service
}

# 关闭 selinux
function disable_selinux() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
}

# 配置ssh
function config_ssh() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    sed -i '/^#UseDNS/cUseDNS no' /etc/ssh/sshd_config
    sed -i '/^GSSAPIAuthentication/cGSSAPIAuthentication no' /etc/ssh/sshd_config
    sed -i '/^GSSAPICleanupCredentials/cGSSAPICleanupCredentials no' /etc/ssh/sshd_config
    sed -i '/^#MaxStartups/cMaxStartups 10000:30:20000' /etc/ssh/sshd_config
}

# 配置网络策略
function config_network() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    chkconfig iptables off; chkconfig ip6tables off; chkconfig postfix off
    systemctl disable postfix; systemctl disable libvirtd; systemctl disable firewalld
    systemctl stop postfix; systemctl stop libvirtd; systemctl stop firewalld
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
