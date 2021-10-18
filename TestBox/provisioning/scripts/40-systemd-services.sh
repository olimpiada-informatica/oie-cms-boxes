#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Adaptado de de https://github.com/cms-orbits/cms-boxes/tree/master/bulky/scripts

readonly user=${DEFAULT_USER-$(whoami)}
readonly SRCDIR=/home/$user/provision-files

# Creamos el directorio para los logs
mkdir /var/log/cms

# Copy systemd units
cp ${SRCDIR}/systemd/* /etc/systemd/system
systemctl daemon-reload

# Enable cmsAdminWebServer, cmsRankingWebServer cmsLogService
systemctl enable cms@AdminWebServer.service cms@RankingWebServer.service cms@LogService.service

# Enable cmsResourceService (with a little naming tweak for semantic purposes)
systemctl enable cmsResourceManager.service cmsProxyService@1.service
