#!/bin/bash

IFNAME="ppp0"
ifconfig |grep ppp0 >/dev/null 2>/dev/null
if [ $? -eq 0 ];then  # La interfaz ppp0 ya esta utilizada (lo mas probable es que por uno de nuestros pinchos)
	IFNAME="ppp1" # Si teniamos dos conexiones ppp la del tunel seria la ppp2, si eso pasa, nos jodemos)
fi


IPREMOTE=`./getip.sh $IFNAME`

echo "/bin/echo \"d username\" > /var/run/xl2tpd/l2tp-control"
/bin/echo "d username" > /var/run/xl2tpd/l2tp-control
sleep 5
echo /etc/init.d/xl2tpd stop
/etc/init.d/xl2tpd stop
sleep 2
echo /etc/init.d/ipsec stop
/etc/init.d/ipsec stop

