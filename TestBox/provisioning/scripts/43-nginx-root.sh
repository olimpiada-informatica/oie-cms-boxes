#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Configuración del comportamiento de nginx con la URL raíz
# (sin ruta). Se apunta a la página de acceso a participantes.
# Posteriormente, cuando se configure el ranking, se cambiará
# y se apuntará a él.

# Cargamos la configuración (para saber si tenemos concurso de prueba)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

readonly ENDPOINTS_DIR="/etc/nginx/sites-available/cms-endpoints"

cp "$ENDPOINTS_DIR/root.conf.contestfrontend" "$ENDPOINTS_DIR/root.conf"
