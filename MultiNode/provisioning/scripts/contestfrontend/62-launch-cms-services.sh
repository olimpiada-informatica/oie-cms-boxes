#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Lanza y habilita los servicios de CMS necesarios
# En este caso, el ResourceManager que lanzará el CWS. Se lanza,
# hasta que se diga lo contrario, para todos los concursos.
enableCMSService.sh cmsResourceManager@ALL.service
