#!/bin/bash
  
/sbin/ifconfig $1 | grep "P-t-P" | gawk -F: '{print $2}' | gawk '{print $1}'
