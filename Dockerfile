FROM centos:latest

COPY initial-tftp /srv/
COPY dnsmasq-pxe.conf start-dnsmasq.sh /root/

RUN mkdir /srv/tftp ;\
    mkdir -p /srv/initial-tftp/{by-hostname,by-mac,by-uuid,pxelinux.cfg}

RUN yum -y update &&\
    yum -y install dnsmasq net-tools syslinux-tftpboot &&\
    cp /usr/share/syslinux/{{mboot,menu,chain}.c32,pxelinux.0,memdisk} /srv/initial-tftp &&\
    yum -y erase syslinux-tftpboot &&\
    yum clean all &&\
    rm -rf /var/cache/yum

# ----------------------------------------------------------------------------
# Bau von iPXE
# http://ipxe.org/howto/msdhcp
# git clone git://git.ipxe.org/ipxe.git

COPY ipxe-master.zip /srv/
RUN yum -y install unzip make gcc perl xz-devel;\
    cd /srv; unzip ipxe-master.zip && \
    cd /srv/ipxe-master/src && \
    sed -ri 's;^//(#define[[:space:]]+)(CONSOLE_CMD|NTP_CMD|REBOOT_CMD)(.*);\1\2\3;g' config/general.h && \
    sed -ri 's;^//(#define[[:space:]]+)(CONSOLE_FRAMEBUFFER)(.*)$;\1\2\3;g' config/console.h && \
    sed -ri 's;^//(#define[[:space:]]+KEYBOARD_MAP).*;\1 de;g' config/console.h && \
    make bin/undionly.kpxe && \
    cp bin/undionly.kpxe /srv/initial-tftp/undionly.kpxe.0 && \
    rm -rf /srv/ipxe-master && \
    yum -y erase unzip make gcc perl xz-devel && \
    yum clean all && rm -rf /var/cache/yum
# ----------------------------------------------------------------------------

VOLUME ["/srv/tftp"]

#EXPOSE 69/UDP
#ENTRYPOINT in.tftpd -s /srv/tftp -4 -L -a 0.0.0.0:69

EXPOSE 67/UDP 68/UDP 69/UDP
ENTRYPOINT ["/root/start-dnsmasq.sh"]

# Test:
# qemu-system-x86_64 -boot n -netdev user,id=net0,bootfile=tftp://172.17.0.2/pxelinux.0 -device virtio-net-pci,netdev=net0
# qemu-system-x86_64 -boot n -netdev user,id=net0,bootfile=tftp://172.17.0.2/undionly.kpxe -device virtio-net-pci,netdev=net0
