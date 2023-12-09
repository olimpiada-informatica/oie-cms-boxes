#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Añade en /etc/hosts la resolución del resto de nodos.
# Se necesitan conocer porque todos aparecen listados en
# la configuración del CMS dentro del ResourceManager para poder
# mostrarlos en la página de administración.
# En realidad solo se necesitan el contestfrontend y el worker,
# pues los otros (nosotros mismos y el main) ya se meten en otros sitios
# (45-patch-localhost-in-hosts y 46-mainNodeInHosts).

echo -e "$WORKER_NODE_IP\t$WORKER_NODE_NAME\t$WORKER_NODE_NAME" >> /etc/hosts
echo -e "$CONTEST_NODE_IP\t$CONTEST_NODE_NAME\t$CONTEST_NODE_NAME" >> /etc/hosts
