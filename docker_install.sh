#!/bin/bash
#by fullblossom-version-0.1-2017/7/3

#安装外部源
cd /etc/yum.repos.d/
mv CentOS-Base.repo CentOS-Base.repo-1
mv CentOS-CR.repo CentOS-CR.repo-1
mv CentOS-Debuginfo.repo CentOS-Debuginfo.repo-1
mv CentOS-fasttrack.repo CentOS-fasttrack.repo-1
mv CentOS-Media.repo CentOS-Media.repo-1
mv CentOS-Vault.repo CentOS-Vault.repo-1
wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
wget http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum makecache
yum repolist

#安装docker
yum -y install docker
systemctl start docker.service
systemctl enable docker.service

#从官网pullcentos镜像
docker pull centos
#查看镜像
docker images
#运行一个容器
docker run -itd  centos /bin/bash
docker images
