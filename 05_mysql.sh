#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-16 15:00:00
#updated: 2023-04-16 15:00:00

set -e 
source 00_env

function start_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    docker-compose -f docker-compose/mysql.yml up -d
}

function init_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    docker exec -it mysql8 mysql -uroot -p$MYSQL_ROOT_PASSWD -e "create database zabbix character set utf8 collate utf8_bin" || true
    docker exec -it mysql8 mysql -uroot -p$MYSQL_ROOT_PASSWD -e "create user 'zabbix'@'%' identified by 'Zabbix'"|| true
    docker exec -it mysql8 mysql -uroot -p$MYSQL_ROOT_PASSWD -e "grant all privileges on zabbix.* to 'zabbix'@'%' with grant option"|| true
    docker exec -it mysql8 mysql -uroot -p$MYSQL_ROOT_PASSWD -e "alter user 'zabbix'@'%' identified with mysql_native_password by 'Zabbix'"|| true
}

function main() {
    echo -e "$CSTART>07_mysql.sh$CEND"

    echo -e "$CSTART>>start_mysql$CEND"
    start_mysql
    
    echo -e "$CSTART>>init_mysql$CEND"
    init_mysql
}

main
