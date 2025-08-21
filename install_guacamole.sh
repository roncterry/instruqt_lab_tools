#!/bin/bash

DEFAULT_LINUX_USER=tux
DEFAULT_LINUX_USER_PASSWORD=linux

GUAC_USER=${DEFAULT_LINUX_USER}
GUAC_USER_PASSWORD=${DEFAULT_LINUX_USER_PASSWORD}
GUAC_USER_PASSWORD_HASH="1980b3ead666faca2b67a71b9a9c1e0b1e169240bb57dac998741204b2855d1f"
GUAC_USER_PASSWORD_SALT="cf48ab767543984b0f142068eee930c0b19dc9905e6e9df620583008489a977b"
GUAC_EXTERNAL_PORT=80
GUAC_TLS_PORT=8443
OPEN_FIREWALL_PORTS="8080/tcp 8443/tcp 15778/tcp 15779/tcp"

LOGFILE=/var/log/install_guacamole.log

##############################################################################

install_guacamole() {
  date | tee -a ${LOGFILE}

  # Retrieve Guacamole Setup
  echo "COMMAND: git clone https://github.com/roncterry/guacamole-setup" | tee -a ${LOGFILE}
  git clone https://github.com/roncterry/guacamole-setup

  # Edit Guacamole configs
  echo "COMMAND: cd guacamole-setup" | tee -a ${LOGFILE}
  cd guacamole-setup
  echo "Editing Guacamole configs ..." | tee -a ${LOGFILE}
  echo "  users_connections.cfg" | tee -a ${LOGFILE}
  sed -i "s+^export GUAC_USER_LIST.*+export GUAC_USER_LIST=\"2,${GUAC_USER},${GUAC_USER_PASSWORD_HASH},${GUAC_USER_PASSWORD_SALT},${GUAC_USER_PASSWORD}\"+" users_connections.cfg
  sed -i "s+^export GUAC_CONNECTION_LIST.*+export GUAC_CONNECTION_LIST=\"1,GUI,rdp,${HOSTNAME}.${_SANDBOX_ID}.instruqt.com,3389,${DEFAULT_LINUX_USER},${DEFAULT_LINUX_USER_PASSWORD},,\"+" users_connections.cfg
  sed -i "s+^export CONNECTION_HOSTNAME_LIST.*+export CONNECTION_HOSTNAME_LIST=\"${HOSTNAME}.${_SANDBOX_ID}.instruqt.com,$(ip addr show eth0 | grep "inet " | awk '{ print $2 }' | cut -d / -f 1)\"+" users_connections.cfg
  sed -i "s+^export USER_CONNECTION_MAPPING_LIST.*+export USER_CONNECTION_MAPPING_LIST=\"${GUAC_USER},GUI\"+" users_connections.cfg

  echo "  guacamole-setup.cfg" | tee -a ${LOGFILE}
  sed -i "s+^export GUACAMOLE_EXTERNAL_PORT.*+export GUACAMOLE_EXTERNAL_PORT=${GUAC_EXTERNAL_PORT}+" guacamole-setup.cfg
  sed -i "s+^export NGINX_TLS_PORT.*+export NGINX_TLS_PORT=${GUAC_TLS_PORT}+" guacamole-setup.cfg
  sed -i "s+^export REQUIRED_FIREWALL_PORTS_LIST.*+export REQUIRED_FIREWALL_PORTS_LIST=\"${OPEN_FIREWALL_PORTS}\"+" guacamole-setup.cfg
  
  # Run Guacamole Setup
  echo "COMMAND: chmod +x *.sh" | tee -a ${LOGFILE}
  chmod +x *.sh
  echo "COMMAND: ./guacamole-setup.sh install" | tee -a ${LOGFILE}
  ./guacamole-setup.sh install

  echo |tee -a ${LOGFILE}
  ls -l ~/guacamole-setup | tee -a ${LOGFILE}
  echo | tee -a ${LOGFILE}
  podman ps |tee -a ${LOGFILE}
  echo | tee -a ${LOGFILE}
}

##############################################################################

install_guacamole

