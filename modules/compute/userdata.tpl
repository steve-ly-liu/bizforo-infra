#!/bin/bash
sleep 20s
sudo yum update -yum
sudo yum install wget -y
sudo yum install unzip -y
sudo yum install mysql-community-server
service mysqld start