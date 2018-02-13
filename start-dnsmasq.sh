#!/bin/bash
if [ -z "$SUBNET" ]; then
       echo "SUBNET nicht gesetzt!"
       exit 1
fi

echo "Host IP: $(hostname --all-ip-addresses)"

ARGS=( )
ARGS+=( --dhcp-range="${SUBNET},proxy,${SUBNET_MASK}" )
if [ -z ${DEBUG+x} ]; then
	ARGS+=( -k )
else
    ARGS+=( --log-dhcp )
	ARGS+=( -d )
fi

set -x
dnsmasq $@ --conf-file=/root/dnsmasq-pxe.conf ${ARGS[@]}
result=$?
set +x
echo "exitcode $result"

[ $result -eq 5 ] && echo "Sicherstellen, dass docker mit --cap-add NET_ADMIN gestartet wurde!"
