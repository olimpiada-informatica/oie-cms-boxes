#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Añade en /etc/hosts la resolución del nodo "worker" pues
# ese nombre es el que aparece en la configuración de CMS

echo -e "$WORKER_NODE_IP\t$WORKER_NODE_NAME\t$WORKER_NODE_NAME" >> /etc/hosts
