FROM openwrt/rootfs:latest

RUN mkdir /var/lock

RUN opkg update

RUN opkg install bash curl nano mailsend qrencode luci-app-sqm https-dns-proxy uhttpd dropbear git

RUN mkdir -p /opt/custom 

ENTRYPOINT ["/bin/bash"]
