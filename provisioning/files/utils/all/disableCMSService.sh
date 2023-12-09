#!/bin/bash
#
# USO: disableCMSService.sh <servicio>
#
# Para y deshabilita un servicio (se supone que de CMS) del systemd para
# que no se lance en los siguientes arranques.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$1" ] && die "No se indicó el identificador del servicio a parar/deshabilitar"

rootOrDie() {
	 if [[ $EUID -ne 0 ]]; then
		  echo Debes ser root para ejecutar este comando 1>&2
		  exit 1
	 fi
}

rootOrDie

systemctl stop "$1"
systemctl disable "$1"
