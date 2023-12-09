#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Lanza y habilita los servicios de CMS necesarios
enableCMSService.sh cms@LogService.service
enableCMSService.sh cms@AdminWebServer.service
enableCMSService.sh cmsResourceManager@ALL.service
enableCMSService.sh cmsRankingWebServer@1.service
enableCMSService.sh cmsProxyService@1.service
