#!/bin/bash

IFNAME="ppp0"
ifconfig |grep ppp0 >/dev/null 2>/dev/null
if [ $? -eq 0 ];then  # La interfaz ppp0 ya esta utilizada (lo mas probable es que por uno de nuestros pinchos)
	IFNAME="ppp1" # Si teniamos dos conexiones ppp la del tunel seria la ppp2, si eso pasa, nos jodemos)
fi
echo /etc/init.d/ipsec start
/etc/init.d/ipsec start
sleep 5                                                   #delay to ensure that IPsec is started before overlaying L2TP
echo /etc/init.d/xl2tpd start
/etc/init.d/xl2tpd start
sleep 5
echo "/bin/echo \"c username\" > /var/run/xl2tpd/l2tp-control"
/bin/echo "c username" > /var/run/xl2tpd/l2tp-control     

sleep 10

IPREMOTE=`./getip.sh $IFNAME`


echo ip ro add 10.10.223.0/24 via $IPREMOTE dev $IFNAME
echo ip ro add 10.10.151.0/24 via $IPREMOTE dev $IFNAME
echo ip ro add 10.10.225.0/24 via $IPREMOTE dev $IFNAME
echo ip ro add 172.20.0.0/21 via $IPREMOTE dev $IFNAME

ip ro add 10.10.223.0/24 via $IPREMOTE dev $IFNAME
ip ro add 10.10.151.0/24 via $IPREMOTE dev $IFNAME
ip ro add 10.10.225.0/24 via $IPREMOTE dev $IFNAME
ip ro add 172.20.0.0/21 via $IPREMOTE dev $IFNAME


sleep 2

ping -c3 gregal.intranet.meteologica.com

