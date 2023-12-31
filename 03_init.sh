#!/bin/bash

#author: Sen Du
#email: dusen.me@gmail.com
#created: 2023-04-16 10:00:00
#updated: 2023-05-06 18:00:00

set -e 
source 00_env

# 安装一些基础软件，便于后续操作
function install_base() {

    system_version="$(cat /etc/centos-release | sed 's/ //g')"
    echo -e "$CSTART>>>>$(hostname -I)>$system_version [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"

    if [[ "$system_version" == RockyLinuxrelease8* ]]; then
        cp rpms/rocky8/epel-release-8-19.el8.noarch.rpm /tmp/
        cp rpms/rocky8/htop-3.2.1-1.el8.x86_64.rpm /tmp/
        cp rpms/rocky8/iotop-0.6-17.el8.noarch.rpm /tmp/
        
        rpm -Uvh /tmp/epel-release-8-19.el8.noarch.rpm || true
        rpm -Uvh /tmp/htop-3.2.1-1.el8.x86_64.rpm || true
        rpm -Uvh /tmp/iotop-0.6-17.el8.noarch.rpm || true
        
        rm -rf /etc/yum.repos.d/epel*
        yum install -y vim wget net-tools || true

    elif [[ "$system_version" == CentOSLinuxrelease7* ]]; then
        cp rpms/centos7/epel-release-7-14.noarch.rpm /tmp/
        cp rpms/centos7/htop-2.2.0-3.el7.x86_64.rpm /tmp/
        cp rpms/centos7/iotop-0.6-4.el7.noarch.rpm /tmp/

        rpm -Uvh /tmp/epel-release-7-14.noarch.rpm || true
        rpm -Uvh /tmp/htop-2.2.0-3.el7.x86_64.rpm || true
        rpm -Uvh /tmp/iotop-0.6-4.el7.noarch.rpm || true
        
        rm -rf /etc/yum.repos.d/epel*
        yum install -y vim wget net-tools || true
    
    elif [[ "$system_version" == CentOSrelease6* ]]; then
        cp rpms/centos6/iotop-0.3.2-9.el6.noarch.rpm $ipaddr:/tmp/
        
        rpm -Uvh /tmp/iotop-0.3.2-9.el6.noarch.rpm || true

        rm -rf /etc/yum.repos.d/epel*
        yum install -y vim wget net-tools || true

    else 
        echo "系统版本[$system_version]超出脚本处理范围" && false
    fi
}

# 配置当前节点的 hostname
function config_hostname() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    echo "hostname=$HOSTNAME" > /etc/sysconfig/network
    echo "$HOSTNAME" > /etc/hostname
    hostnamectl set-hostname $HOSTNAME
}

# 备份一些配置文件
function backup_configs() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    mkdir -p /opt/backup/configs_$(date '+%Y%m%d')
}

# 设置时区为 Asia/Shanghai
function set_timezone() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    # 创建时区软链接
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime || true
    # 如果软链接已经存在，修改它，避免第一步失败
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

# 禁用 hugepage
function disable_hugepage() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    grubby --update-kernel=ALL --args='transparent_hugepage=never'
    sed -i '/^#RemoveIPC=no/cRemoveIPC=no' /etc/systemd/logind.conf
    systemctl restart systemd-logind.service
}

# 关闭 selinux
function disable_selinux() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    cp /etc/selinux/config /opt/backup/configs_$(date '+%Y%m%d')/etc_selinux_config
    sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
    setenforce 0 || true
}

# 配置 ssh
function config_ssh() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    cp /etc/ssh/sshd_config /opt/backup/configs_$(date '+%Y%m%d')/etc_ssh_sshd_config
    sed -i '/^#UseDNS/cUseDNS no' /etc/ssh/sshd_config
    sed -i '/^GSSAPIAuthentication/cGSSAPIAuthentication no' /etc/ssh/sshd_config
    sed -i '/^GSSAPICleanupCredentials/cGSSAPICleanupCredentials no' /etc/ssh/sshd_config
    sed -i '/^#MaxStartups/cMaxStartups 10000:30:20000' /etc/ssh/sshd_config
    systemctl restart sshd || service sshd restart || true
}

# 配置网络策略
function config_network() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
        ssh -n $ipaddr "chkconfig iptables off; chkconfig ip6tables off; chkconfig postfix off" || true
        ssh -n $ipaddr "systemctl disable postfix; systemctl disable libvirtd; systemctl disable firewalld" || true
        ssh -n $ipaddr "systemctl stop postfix; systemctl stop libvirtd; systemctl stop firewalld" || true
    done
}

# 调优 sysctl
function config_sysctl() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    cp /etc/sysctl.conf /opt/backup/configs_$(date '+%Y%m%d')
    cp config/sysctl.conf /etc/sysctl.conf
    sysctl -p
}

# 调优 limits
function config_limits() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    cp /etc/security/limits.conf /opt/backup/configs_$(date '+%Y%m%d')
    cp config/limits.conf /etc/security/limits.conf
}

# 关闭 swap
function disable_swap() {
    echo -e "$CSTART>>>>$(hostname -I) [$(date +'%Y-%m-%d %H:%M:%S')]$CEND"
    cp /etc/fstab /opt/backup/configs_$(date '+%Y%m%d')
    sed -i '/swap / s/^\(.*\)$/#\1/g' /etc/fstab
    swapoff -a
}

function main() {
    echo -e "$CSTART>03_init.sh$CEND"
    
    echo -e "$CSTART>>install_base$CEND"
    install_base

    echo -e "$CSTART>>backup_configs$CEND"
    backup_configs

    echo -e "$CSTART>>set_timezone$CEND"
    set_timezone

    echo -e "$CSTART>>disable_hugepage$CEND"
    disable_hugepage || true

    echo -e "$CSTART>>disable_selinux$CEND"
    disable_selinux

    echo -e "$CSTART>>config_ssh$CEND"
    config_ssh

    echo -e "$CSTART>>config_network$CEND"
    config_network

    echo -e "$CSTART>>config_sysctl$CEND"
    config_sysctl
    
    echo -e "$CSTART>>config_limits$CEND"
    config_limits

    echo -e "$CSTART>>disable_swap$CEND"
    disable_swap
}

main
