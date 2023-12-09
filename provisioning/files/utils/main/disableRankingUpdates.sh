#!/bin/bash
#
# USO: disableRankingUpdates.sh <rankingId>
#
# Configura el Proxy Server para que deje de enviar notificaciones de
# actualización al ranking indicado como parámetro.
#
# Script muy dependiente de que en la instalación se hayan preparado
# los directorios correctamente.
#
# Recibe como parámetro el id del ranking correspondiente.
#
# Utiliza el fichero de configuración para extraer usuario
# y contraseña y lo añade en la configuración del ProxyServer de CMS.

readonly RANKING_BASE_FOLDER="/home/cms/rankings"

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

disableRankingUpdates () {

  local rankingsBaseFolder="$RANKING_BASE_FOLDER"
  local num=$1
  local rankingFolder="$rankingsBaseFolder/ranking$num"
  local configFile="$rankingsBaseFolder/cms.ranking$num.conf"

  [ ! -e $configFile ] && die "Ranking $2 no encontrado."

  # Leemos la configuración del ranking server correspondiente
  local RANKING_USER=$(< "$configFile" jq -r '.username')
  local RANKING_PASSWORD=$(< "$configFile" jq -r '.password')
  local RANKING_PORT=$(< "$configFile" jq -r '.http_port')

  # Parcheamos
  patchLocalConfigFile.sh '.rankings-=["http://'$RANKING_USER':'$RANKING_PASSWORD'@localhost:'$RANKING_PORT'/"]'

  # La instalamos
  installLocalConfigFile.sh

  # Y relanzamos ProxyService
  systemctl restart cmsProxyService@$(getActiveContest.sh).service
}

[ -z "$1" ] && die "No se indicó el número de ranking"

rootOrDie
disableRankingUpdates "$@"
