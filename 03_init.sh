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

function main() {
    echo -e "$CSTART>03_init.sh$CEND"

    echo -e "$CSTART>>install_base$CEND"
    install_base
}

main
