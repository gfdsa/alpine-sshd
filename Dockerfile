###########################################
# Official Image Alpine with OpenSSH server
# Allow SSH connection to the container
# Installed: openssh-server, mc, htop, zip,
# tar, iotop, ncdu, nano, vim, bash, sudo
# for net: ping, traceroute, telnet, host,
# nslookup, iperf, nmap
###########################################

ARG IMAGE_VERSION="alpine:latest"

FROM $IMAGE_VERSION
# Label docker image
ARG IMAGE_VERSION
LABEL build_version="Image version:- ${IMAGE_VERSION}"

# Base
# Set the locale

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Copy to image
COPY copyables /

# Install
RUN apk update \
	&& apk add --no-cache --upgrade openssh-server vim bash sed \
# Deleting keys
	&& rm -rf /etc/ssh/ssh_host_dsa* /etc/ssh/ssh_host_ecdsa* /etc/ssh/ssh_host_ed25519* /etc/ssh/ssh_host_rsa* \
# Config SSH
        && sed -i -e "s|#PubkeyAuthentication yes|PubkeyAuthentication yes|" \
               -e "s|#Password Authentication yes|PasswordAuthentication no|" \
               -e "s|AllowTcpForwarding no|AllowTcpForwarding yes|" \
          /etc/ssh/sshd_config \ 
# Folder Data
	&& mkdir -p /data \
#Cleaning
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/ \
	&& rm -rf /var/lib/apt/lists/*.lz4 \
	&& rm -rf /var/log/* \	
	&& rm -rf /tmp/* \
	&& rm -rf /var/tmp/* \
	&& rm -rf /usr/share/doc/ \
	&& rm -rf /usr/share/man/ \	
	&& rm -rf /var/cache/apk/* \
	&& rm -rf $HOME/.cache \
	&& chmod +x /entrypoint.sh

RUN adduser -g User -D user && mkdir -p /home/user/.ssh && chmod 700 /home/user/.ssh && passwd -u user
COPY user-keys /user-keys
RUN bash -c "cat /user-keys/*.pub > /home/user/.ssh/authorized_keys" && rm -fr /user-keys && chown -R user:user /home/user && chmod 600 /home/user/.ssh/authorized_keys

# Port SSH
EXPOSE 22/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e"]
