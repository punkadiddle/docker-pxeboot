#!/bin/bash

unzip ipxe-master.zip
cd ipxe-master/src
sed -ri 's;^//(#define[[:space:]]+)(CONSOLE_CMD|NTP_CMD|REBOOT_CMD)(.*);\1\2\3;g' config/general.h
sed -ri 's;^//(#define[[:space:]]+)(CONSOLE_FRAMEBUFFER)(.*)$;\1\2\3;g' config/console.h
sed -ri 's;^//(#define[[:space:]]+KEYBOARD_MAP).*;\1 de;g' config/console.h

make bin/undionly.kpxe 
#EMBED=../../init.ipxe
cp bin/undionly.kpxe ../../initial-tftp/undionly.0
