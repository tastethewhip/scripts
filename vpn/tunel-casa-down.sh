#!/bin/sh

/etc/init.d/openvpn stop && cat $(dirname $0)/dns-casa | resolvconf -a eth1


