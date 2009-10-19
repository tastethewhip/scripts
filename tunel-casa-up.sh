#!/bin/sh

cp -pf /etc/resolv.conf resolv.orig
cp -pf resolv-tunel.conf /etc/resolv.conf
/etc/init.d/openvpn restart

