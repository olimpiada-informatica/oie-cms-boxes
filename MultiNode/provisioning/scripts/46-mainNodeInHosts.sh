#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Añade en /etc/hosts la resolución del nodo "main" pues
# ese nombre es el que aparece en la configuración de CMS

echo -e "$MAIN_NODE_IP\t$MAIN_NODE_NAME\t$MAIN_NODE_NAME" >> /etc/hosts
