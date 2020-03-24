#! /bin/bash

yum update -y
amazon-linux-extras install nginx1.12
systemctl enable nginx
systemctl start nginx
