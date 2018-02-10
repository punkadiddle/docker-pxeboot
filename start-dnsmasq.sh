#!/bin/bash
if [ -z "$SUBNET" ]; then
       echo "SUBNET nicht gesetzt!"
       exit 1
fi

ifconfig eth0

set -x
dnsmasq $@ --conf-file=/root/dnsmasq-pxe.conf --dhcp-range="${SUBNET},proxy" -k
result=$?
set +x
echo "exitcode $result"

[ $result -eq 5 ] && echo "Sicherstellen, dass docker mit --cap-add NET_ADMIN gestartet wurde!"
