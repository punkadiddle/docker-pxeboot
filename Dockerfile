FROM centos:latest

COPY initial-tftp /srv/initial-tftp
COPY dnsmasq-pxe.conf start-dnsmasq.sh init.ipxe /root/

RUN mkdir /srv/tftp ;\
    mkdir -p /srv/initial-tftp/{by-hostname,by-mac,by-uuid,pxelinux.cfg}

RUN yum -y install dnsmasq syslinux-tftpboot &&\
    cp /usr/share/syslinux/{{mboot,menu,chain}.c32,pxelinux.0,memdisk} /srv/initial-tftp &&\
    yum -q -y erase syslinux-tftpboot &&\
    yum -q -y autoremove && yum clean all && rm -rf /var/cache/yum

# ----------------------------------------------------------------------------
# iPXE build (needs to be copied to /srv/tftp manually)
# git://git.ipxe.org/ipxe.git

#COPY ipxe-master.zip /srv/
RUN yum -y install wget unzip make gcc perl xz-devel && \
    wget https://git.ipxe.org/ipxe.git/snapshot/546dd51de8459d4d09958891f426fa2c73ff090d.zip -O /srv/ipxe-master.zip && \
    cd /srv; unzip ipxe-master.zip && \
    cd $(find /srv -maxdepth 1 -type d -name 'ipxe-*')/src && \
    sed -ri 's;^/+(#define[[:space:]]+)(CONSOLE_CMD|NTP_CMD|REBOOT_CMD)(.*);\1\2\3;g' config/general.h && \
    sed -ri 's;^/+(#define[[:space:]]+)(CONSOLE_FRAMEBUFFER)(.*)$;\1\2\3;g' config/console.h && \
    sed -ri 's;^/*(#define[[:space:]]+KEYBOARD_MAP).*;\1 de;g' config/console.h && \
    make -j3 bin/undionly.kpxe bin-x86_64-efi/ipxe.efi bin-i386-efi/ipxe.efi EMBED=/root/init.ipxe && \
    cp -v bin/undionly.kpxe /srv/initial-tftp/undionly.kpxe && \
    cp -v bin-x86_64-efi/ipxe.efi /srv/initial-tftp/ipxe.efi && \
    cp -v bin-i386-efi/ipxe.efi /srv/initial-tftp/ipxe32.efi && \
    rm -rf /srv/ipxe-* && \
    yum -q -y erase unzip make wget gcc perl xz-devel && \
    yum -q -y autoremove && yum clean all && rm -rf /var/cache/yum
# ----------------------------------------------------------------------------

VOLUME ["/srv/tftp"]

#EXPOSE 69/UDP
#ENTRYPOINT in.tftpd -s /srv/tftp -4 -L -a 0.0.0.0:69

EXPOSE 67/UDP 68/UDP 69/UDP
ENTRYPOINT ["/root/start-dnsmasq.sh"]

# Test:
# qemu-system-x86_64 -boot n -netdev user,id=net0,bootfile=tftp://172.17.0.2/pxelinux.0 -device virtio-net-pci,netdev=net0
# qemu-system-x86_64 -boot n -netdev user,id=net0,bootfile=tftp://172.17.0.2/undionly.kpxe.0 -device virtio-net-pci,netdev=net0

# Login to grab initial files:
# docker exec -ti <id> /bin/bash

