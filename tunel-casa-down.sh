#!/bin/sh

cp -pf resolv.orig /etc/resolv.conf
#cp -pf resolv-tinel.conf /etc/resolv.conf
/etc/init.d/openvpn stop

