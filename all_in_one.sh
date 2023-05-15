#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-05-15 10:00:00
#updated: 2023-05-15 10:00:00

set -e 
source 00_env

# all in one
function main() {
    /bin/bash ./01_sshpass.sh
    /bin/bash ./02_hosts.sh
    /bin/bash ./03_init.sh
    /bin/bash ./04_docker.sh
    /bin/bash ./05_zabbix_server.sh
    /bin/bash ./06_zabbix_agent.sh
}

main
