#!/bin/sh

cp -pf /etc/resolv.conf /etc/resolv.orig
cp -pf resolv-tunel.conf /etc/resolv.conf
/etc/init.d/openvpn restart

