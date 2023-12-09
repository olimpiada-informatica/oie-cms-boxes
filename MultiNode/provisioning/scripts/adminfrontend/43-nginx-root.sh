#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Configuración del comportamiento de nginx con la URL raíz
# (sin ruta) lleva a la página de administración.

readonly ENDPOINTS_DIR="/etc/nginx/sites-available/cms-endpoints"

cp "$ENDPOINTS_DIR/root.conf.adminfrontend" "$ENDPOINTS_DIR/root.conf"
