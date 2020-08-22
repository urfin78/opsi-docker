#!/bin/bash
set -x
/usr/bin/opsi-setup --set-rights
apt-get -qq -o DPkg::options::=--force-confmiss --reinstall install python-opsi opsiconfd opsi-depotserver opsi-utils
/usr/bin/opsi-setup --init-current-config
/usr/bin/opsi-setup --set-rights
/usr/bin/opsi-setup --auto-configure-samba
/usr/bin/opsi-package-updater -vv update
/usr/sbin/smbd & /usr/bin/opsiconfd
