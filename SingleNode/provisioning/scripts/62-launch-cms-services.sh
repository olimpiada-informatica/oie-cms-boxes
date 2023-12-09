#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Cargamos la configuración (para el número de rankings)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x   
fi

# Lanza y habilita los servicios de CMS necesarios
enableCMSService.sh cms@LogService.service
enableCMSService.sh cms@AdminWebServer.service
enableCMSService.sh cmsProxyService@1.service
enableCMSService.sh cmsResourceManager@ALL.service

for c in $(seq 1 ${NUM_RANKINGS-3}); do
    enableCMSService.sh cmsRankingWebServer@$c.service
done
