#!/bin/bash
#
# USO: activeContest.sh <id>
#
# Configura CMS para tener un concurso concreto activo. El concurso
# activo es el que determina:
#
#    - A qué concurso pueden hacer login los participantes
#    - A qué concurso atienden los workers
#    - De qué concurso se notifica el progreso a los rankings
#    - ...
#
# La ejecución del comando:
#
#    - Desactiva el concurso activo.
#    - Activa el concurso nuevo.
#    - Configura los servicios para que el concurso siga activo
# también tras reinicios.
#
# Debe ejecutarse como root, pues cambia los servicios del sistema
# (parando los viejos y lanzando y habilitando los nuevos).
#
# Los servicios que para/lanza son:
#
#    - El cmsResourceManager. En el main es responsable de los
# servicios adicionales Evaluation, Scoring, Worker y Checker asociados al
# nuevo concurso. En el contestfrontend se encarga de lanzar el ContestServer.
#    - El cmsProxyServer. Solo se lanza si en el fichero de configuración
# de CMS hay una entrada para él. De esta forma el script es el mismo
# tanto en el main (donde sí hay entrada y hay que lanzarlo) como en
# el contestfrontend (donde no hay entrada y no hay que lanzarlo). El
# ProxyServer es el encargado de avisar a los rankings habilitados de
# los cambios en el concurso. Es importante lanzarlo porque si no se
# hiciera el propio cmsResourceManager tomaría la iniciativa y lo haría,
# pero quedaría entonces "fuera de nuestro control" pues ya no podríamos
# activarlo y desactivarlo a voluntad cuando, por ejemplo, cambie su
# fichero de configuración al habilitar/deshabilitar rankings.
#
# Requiere que getActiveContest.sh esté en el path

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

rootOrDie

[ -z "$1" ] && die "No se indicó el identificador del concurso"

CURRENT=$(getActiveContest.sh)

if [[ "$1" == "$CURRENT" ]]; then
   echo "El concurso $1 es el concurso activo. No hacemos nada"
   #exit 0
fi

if [ -n "$CURRENT" ]; then
    echo "Deshabilitamos servicios relacionados con el concurso $CURRENT"
    # Deshabilitamos y paramos anterior.
    disableCMSService.sh "cmsResourceManager@$CURRENT.service"
    if [ "$(cat /usr/local/etc/cms.conf | jq '.core_services.ProxyService | length')" -gt 0 ]; then
        disableCMSService.sh "cmsProxyService@$CURRENT.service"
    fi
fi

echo "Habilitamos servicios relacionados con el concurso $1"

# Habilitamos y lanzamos resource manager (que activará Evaluation, Scoring, Worker
# y Checker asociados)
enableCMSService.sh "cmsResourceManager@$1.service"

# Habilitamos y lanzamos ProxyService configurado para el concurso concreto,
# si hay ProxyService configurado.
if [ "$(cat /usr/local/etc/cms.conf | jq '.core_services.ProxyService | length')" -gt 0 ]; then
    enableCMSService.sh "cmsProxyService@$1.service"
fi

# Sanity-check. Damos un tiempo para que los servicios se lancen (o fallen)
sleep 2
CURRENT=$(getActiveContest.sh)

if [[ "$1" != "$CURRENT" ]]; then
    echo "Aviso: parece que el concurso $1 no se ha lanzado bien (¿no existe?). Revisa los logs de los servicios. O quizá simplemente estén aún lanzándose y este mensaje sea una falsa alarma." 2>&1 
fi
