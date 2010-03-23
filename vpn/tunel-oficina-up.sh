#!/bin/sh
/etc/init.d/openvpn restart
iptables -A FORWARD -i tun+ -j ACCEPT
ip ro sh
echo 1 > /proc/sys/net/ipv4/ip_forward
echo  ATENCION, EL NOMBRE DE LA INTERFAZ PUEDE CAMBIAR
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
#iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
