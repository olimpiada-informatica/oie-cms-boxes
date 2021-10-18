#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Adaptado de de https://github.com/cms-orbits/cms-boxes/tree/master/bulky/scripts

# Crea la BBDD de CMS y el usuario administrador

# Cargamos la configuración (para usuario y contraseña de administrador,
# $ADMIN_USER y $ADMIN_PASSWORD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x   
fi

# Crea la BBDD
initialBD() {
  cmsInitDB
}

# Create First Admin user
initialAdmUsr() {
  set +x
  local adminuser=${ADMIN_USER-admin}
  local adminpswd=${ADMIN_PASSWORD-admin}
  cmsAddAdmin "$adminuser" --password "$adminpswd"
  set -x
}

initialBD
initialAdmUsr
