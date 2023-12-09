#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Lanza y habilita los servicios de CMS necesarios
enableCMSService.sh cmsResourceManager@ALL.service
