#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Configuración del comportamiento de nginx con la URL raíz
# (sin ruta). En esta máquina no hay servicios de HTTP fijos,
# por lo que no se configura ninguno.
#
# Si en una fase posterior se determina que hay rankings, se
# configurará el raíz para apuntar al primero.
