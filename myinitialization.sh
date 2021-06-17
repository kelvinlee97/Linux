#!/bin/sh

#install basic tools
yum install -y epel-release
yum install -y vim-enhanced wget lrzsz gcc-c++ openssl-devel pcre-devel zlib-devel libselinux-python net-tools
yum -y groupinstall 'Development Libraries' 'Development Tools'

#disabled selinux [Centos 7]
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" `grep -rl "SELINUX=enforcing" /etc/selinux/config`

#disabled firewalld
systemctl stop firewalld
systemctl disable firewalld

wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.68/bin/apache-tomcat-8.5.68.tar.gz /opt
