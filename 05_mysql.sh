#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 15:00:00
#updated: 2023-04-16 15:00:00

set -e 
source 00_env

function start_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    docker-compose -f mysql8/docker-compose.yml up -d
}

function main() {
    echo -e "$CSTART>07_mysql.sh$CEND"

    echo -e "$CSTART>>start_mysql$CEND"
    start_mysql
}

main
