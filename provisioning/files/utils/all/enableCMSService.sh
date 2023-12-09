#!/bin/bash
#
# USO: enableCMSService.sh <servicio>
#
# Lanza y habilita un servicio (se supone que de CMS) del systemd para
# que se lance en los siguientes arranques.

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

systemctl start "$1"
systemctl enable "$1"
