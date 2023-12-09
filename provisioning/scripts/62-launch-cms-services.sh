#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# En este punto se pueden lanzar los distintos servicios de CMS
# y habilitarlos en el systemd para que se lancen en cada arranque.
# Los servicios concretos son específicos de cada máquina/nodo, por
# lo que se encuentran en los directorios específicos de
# cada uno.
