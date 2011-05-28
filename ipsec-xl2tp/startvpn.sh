#!/bin/bash

echo /etc/init.d/ipsec start
/etc/init.d/ipsec start
sleep 5                                                   #delay to ensure that IPsec is started before overlaying L2TP
echo /etc/init.d/xl2tpd start
/etc/init.d/xl2tpd start
sleep 5
echo "/bin/echo \"c username\" > /var/run/xl2tpd/l2tp-control"
/bin/echo "c username" > /var/run/xl2tpd/l2tp-control     
#PPP_GW_ADD=`./getip.sh ppp0`

