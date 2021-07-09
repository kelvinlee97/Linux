#!/bin/sh

#install basic tools
yum install -y epel-release
yum install -y vim-enhanced wget lrzsz gcc-c++ openssl-devel pcre-devel zlib-devel libselinux-python net-tools dpkg
yum -y groupinstall 'Development Libraries' 'Development Tools'

#disabled selinux [Centos 7]
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" `grep -rl "SELINUX=enforcing" /etc/selinux/config`

#disabled firewalld
systemctl stop firewalld
systemctl disable firewalld

#update & upgrade server
yum update
yum upgrade

#download apache tomcat 8
wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.68/bin/apache-tomcat-8.5.68.tar.gz /opt



#set enviroment variable for JAVA 8 ( NOT COMPLETE )
JAVA_HOME=/opt/jdk
export JAVA_HOME
CLASSPATH=.:$JAVA_HOME/lirootb:$JAVA_HOME/jre/lib
export CLASSPATH
JRE=$JAVA_HOME/jre
export JRE
PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export PATH
