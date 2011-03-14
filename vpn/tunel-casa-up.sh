#!/bin/sh

/etc/init.d/openvpn restart && cat $(dirname $0)/dns-oficina | resolvconf -a eth1

