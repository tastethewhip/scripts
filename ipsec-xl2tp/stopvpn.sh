#!/bin/bash

/bin/echo "d username" > /var/run/xl2tpd/l2tp-control
/etc/init.d/xl2tpd stop
/etc/init.d/ipsec stop

#route delete 68.68.32.79 gw 192.168.1.1 eth0
#route add default gw 192.168.1.1
