FROM debian:10-slim
ENV DEBIAN_FRONTEND=noninteractive
ARG OPSI_USER=opsi
ARG OPSI_PASSWORD=insecure
RUN apt-get -y update && apt-get -y install wget host pigz samba samba-common smbclient cifs-utils openssh-client cpio
RUN echo "deb http://download.opensuse.org/repositories/home:/uibmz:/opsi:/4.1:/stable/Debian_10/ /" > /etc/apt/sources.list.d/opsi.list
RUN wget -nv https://download.opensuse.org/repositories/home:uibmz:opsi:4.1:stable/Debian_10/Release.key -O Release.key && apt-key add - < Release.key
RUN apt-get -y update && apt-get -y install opsi-tftpd-hpa opsi-server opsi-windows-support && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN /usr/sbin/useradd -m -s /bin/bash $OPSI_USER
RUN echo "$OPSI_USER:$OPSI_PASSWORD" | chpasswd
RUN (echo "${OPSI_PASSWORD}"; echo "${OPSI_PASSWORD}") | smbpasswd -s -a $OPSI_USER
RUN mkdir -p /var/lib/opsi/repository && mkdir -p /usr/lib/configed && mkdir -p /var/run/opsiconfd && chown -R opsiconfd /var/run/opsiconfd && chown -R opsiconfd /usr/lib/configed
RUN /usr/sbin/usermod -aG opsiadmin $OPSI_USER
RUN /usr/sbin/usermod -aG pcpatch $OPSI_USER
COPY ./scripts/entrypoint.sh /usr/local/bin/
RUN echo ".* :file" > /etc/opsi/backendManager/dispatch.conf
RUN sed -i '/active/s/= .*/= true/' /etc/opsi/package-updater.repos.d/uib-local_image.repo && sed -i '/autoInstall/s/= .*/= true/' /etc/opsi/package-updater.repos.d/uib-local_image.repo
RUN chown ${OPSI_USER}:${OPSI_USER} /usr/local/bin/entrypoint.sh && chmod 755 /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]