# Zabbix 离线安装

先在一台机器安装 Server，然后在其他机器安装 Agent

- Zabbix 版本：6.4
- 系统版本：Centos 7.6

*****

## 前提

## 一、Zabbix 安装

### 0. 配置环境变量
- 需要手动补充该文件中的配置项
- [./00_env](./00_env)

### 1. 配置集群间ssh免密
- 需要修改 `config/vm_info` 文件
- [./01_sshpass.sh](./01_sshpass.sh)

### 2. 配置所有节点的 hosts
- 需要修改 `config/vm_info` 文件
- [./02_hosts.sh](./02_hosts.sh)

### 3. 初始化系统环境
- [./03_init.sh](./03_init.sh)


## 其它：
1. docker 镜像导入导出
```bash
docker save --output mysql.8.0.33.tar mysql:8.0.33
tar -zcvf mysql.8.0.33.tar.gz mysql.8.0.33.tar
mv mysql.8.0.33.tar.gz /opt/zabbix-parcels/

tar -zxvf /opt/zabbix-parcels/mysql.8.0.33.tar.gz -C /tmp/
docker import /tmp/mysql.8.0.33.tar mysql:8.0.33
```

## Refs:
- Docker离线安装：https://www.cnblogs.com/xiongzaiqiren/p/16900429.html
