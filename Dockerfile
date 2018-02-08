FROM centos:latest

RUN yum update;\
    yum install -y tftp-server syslinux syslinux-tftpboot

RUN mkdir -p /srv/tftp/{pxelinux.cfg}
RUN cp /usr/share/syslinux/{{mboot,menu,chain}.c32,pxelinux.0,memdisk} /srv/tftp
RUN mkdir -p /srv/tftp/{by-uuid,by-hostname,by-mac}
COPY default /srv/tftp/pxelinux.cfg/
COPY boot.ipxe* /srv/tftp/
COPY menu.ipxe* /srv/tftp/
COPY *.kpxe /srv/tftp/
COPY ipxe.png /srv/tftp/
RUN mkdir /srv/tftp/a
COPY a/* /srv/tftp/a/

# ----------------------------------------------------------------------------
# Bau von iPXE
# http://ipxe.org/howto/msdhcp
# git clone git://git.ipxe.org/ipxe.git

#RUN yum -y install unzip make gcc perl xz-devel
#WORKDIR /tmp
#COPY ipxe-master.zip .
#COPY init.ipxe .
#RUN unzip ipxe-master.zip
#WORKDIR /tmp/ipxe-master/src
#RUN sed -ri 's;^//(#define[[:space:]]+)(CONSOLE_CMD|NTP_CMD|REBOOT_CMD)(.*);\1\2\3;g' config/general.h;\
#    sed -ri 's;^//(#define[[:space:]]+)(CONSOLE_FRAMEBUFFER)(.*)$;\1\2\3;g' config/console.h;\
#    sed -ri 's;^//(#define[[:space:]]+KEYBOARD_MAP).*;\1 de;g' config/console.h
#RUN make bin/undionly.kpxe EMBED=/tmp/init.ipxe
#RUN cp /tmp/ipxe-master/src/bin/undionly.kpxe /srv/tftp/
#RUN cp /tmp/ipxe-master/src/bin/undionly.kpxe /srv/
#RUN rm -rf /tmp/ipxe-master* /tmp/*.ipxe
#RUN yum -y remove unzip make gcc perl xz-devel
# ----------------------------------------------------------------------------


ENV LISTEN_IP=0.0.0.0
ENV LISTEN_PORT=69
EXPOSE $LISTEN_PORT/UDP
ENTRYPOINT in.tftpd -s /srv/tftp -4 -L -a $LISTEN_IP:$LISTEN_PORT

# Test:
# qemu-system-x86_64 -boot n -netdev user,id=net0,bootfile=tftp://172.17.0.2/pxelinux.0 -device virtio-net-pci,netdev=net0
# qemu-system-x86_64 -boot n -netdev user,id=net0,bootfile=tftp://172.17.0.2/undionly.kpxe -device virtio-net-pci,netdev=net0
