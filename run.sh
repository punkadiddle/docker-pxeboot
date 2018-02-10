#!/bin/bash
docker run --rm --network host -e SUBNET=192.168.1.0 --volume "$PWD/initial-tftp:/srv/tftp:ro" --cap-add NET_ADMIN pxe-boot

