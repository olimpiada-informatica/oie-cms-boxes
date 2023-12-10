#!/bin/bash
#
# USO: restartCMSService.sh <servicio>
#
# Relanza un servicio (se supone que de CMS) ya lanzado. Se utiliza
# tras cambiar el fichero de configuración de CMS.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$1" ] && die "No se indicó el identificador del servicio a lanzar/habilitar"

rootOrDie() {
	 if [[ $EUID -ne 0 ]]; then
		  echo Debes ser root para ejecutar este comando 1>&2
		  exit 1
	 fi
}

rootOrDie

systemctl restart "$1"
