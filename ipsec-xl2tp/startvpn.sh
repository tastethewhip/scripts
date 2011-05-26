#!/bin/bash

/etc/init.d/ipsec start
sleep 10                                                   #delay to ensure that IPsec is started before overlaying L2TP
/etc/init.d/xl2tpd start
sleep 10
/bin/echo "c username" > /var/run/xl2tpd/l2tp-control     
#PPP_GW_ADD=`./getip.sh ppp0`

ip ro add 10.10.223.0/24 via 10.64.64.64 dev ppp0
ip ro add 10.10.225.0/24 via 10.64.64.64 dev ppp0
ip ro add 172.20.0.0/21 via 10.64.64.64 dev ppp0
ip ro del default via 10.64.64.64 dev ppp0 


#route add 68.68.32.79 gw 192.168.1.1 eth0
#route add default gw $PPP_GW_ADD
#route delete default gw 192.168.1.1
