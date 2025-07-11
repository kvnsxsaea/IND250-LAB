#!/bin/bash
sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables
sudo touch /etc/sysctl.d/custom-ip-forwarding.conf
sudo sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/custom-ip-forwarding.conf'
sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf
INTERFACE="$(route | grep '^default' | grep -o '[^ ]*$')"
sudo /sbin/iptables -t nat -A POSTROUTING -o "$INTERFACE" -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo service iptables save
