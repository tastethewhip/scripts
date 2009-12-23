#!/bin/sh
route del default 
route add default gw 192.168.2.1 eth0
ping -c 3 www.google.es
