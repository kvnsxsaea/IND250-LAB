#!/bin/bash

dnf update -y

dnf install -y mariadb105-server mariadb105

systemctl start mariadb
systemctl enable mariadb

sleep 10

mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'superpwd123';

CREATE USER IF NOT EXISTS 'ind250'@'localhost' IDENTIFIED BY 'ind250psw';

GRANT ALL PRIVILEGES ON *.* TO 'ind250'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF