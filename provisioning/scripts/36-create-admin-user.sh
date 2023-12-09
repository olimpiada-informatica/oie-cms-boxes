#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Crea el usuario administrador del AdminWebServer
# Se hace únicamente si tenemos el rol main, pues es donde está la BBDD.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

# Cargamos la configuración (para usuario y contraseña de administrador,
# $ADMIN_USER y $ADMIN_PASSWORD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x   
fi

# Create First Admin user
initialAdmUsr() {

  # Si no tenemos el rol main, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  set +x
  local adminuser=${ADMIN_USER-admin}
  local adminpswd=${ADMIN_PASSWORD-admin}
  cmsAddAdmin "$adminuser" --password "$adminpswd"
  set -x
}

initialAdmUsr
