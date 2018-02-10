## PXEBOOT

An out-of-the-box start and use TFTP PXE server with CentOS 7 online installation pre-configured.

#### How to use

For out-of-the-box running

`docker build -t pxe-boot --compress .; docker run --rm -ti -e SUBNET=192.168.1.0 --volume "$HOME/git/docker-pxeboot/initial-tftp:/srv/tftp:ro" --cap-add NET_ADMIN --network host pxe-boot`

Configure your DHCP server to give the container IP for next-server and pxelinux.0 as the filename.

