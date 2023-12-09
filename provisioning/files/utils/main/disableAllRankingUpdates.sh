#!/bin/bash
#
# USO: disableAllRankingUpdates.sh
#
# Configura el Proxy Server para que deje de enviar notificaciones de
# actualización a todos los rankings.
#
# Script muy dependiente de que en la instalación se hayan preparado
# los directorios correctamente.

die() {
    echo $@ 2>&1
    exit 1
}

rootOrDie() {
	 if [[ $EUID -ne 0 ]]; then
		  echo Debes ser root para ejecutar este comando 1>&2
		  exit 1
	 fi
}

disableAllRankingUpdates () {

  # Quitamos todos los rankings de la configuración de CMS
  # (donde lee el ProxyServer)
  patchLocalConfigFile.sh '.rankings=[]'

  # La instalamos
  installLocalConfigFile.sh

  # Y relanzamos ProxyService
  systemctl restart cmsProxyService@$(getActiveContest.sh).service

}

rootOrDie
disableAllRankingUpdates
