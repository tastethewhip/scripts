#!/bin/bash

echo "/bin/echo \"d username\" > /var/run/xl2tpd/l2tp-control"
/bin/echo "d username" > /var/run/xl2tpd/l2tp-control
sleep 2
echo /etc/init.d/xl2tpd stop
/etc/init.d/xl2tpd stop
sleep 5
echo /etc/init.d/ipsec stop
/etc/init.d/ipsec stop

#route delete 68.68.32.79 gw 192.168.1.1 eth0
#route add default gw 192.168.1.1
