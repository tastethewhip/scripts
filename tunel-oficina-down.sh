#!/bin/sh
/etc/init.d/openvpn stop
#iptables -A FORWARD -i tun+ -j ACCEPT
#ip ro sh
#echo 1 > /proc/sys/net/ipv4/ip_forward
#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
