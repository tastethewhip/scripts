#!/bin/sh

cp -pf /etc/resolv.conf /etc/resolv.orig
echo "domain intranet.meteologica.com" > /etc/resolv.conf
echo "domain prod.meteologica.com" >> /etc/resolv.conf
echo "nameserver 172.20.1.50" >> /etc/resolv.conf
/etc/init.d/openvpn restart

