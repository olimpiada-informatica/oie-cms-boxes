#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Crea el usuario de postgresql que se utilizará
# Se hace únicamente si tenemos el rol main, pues es donde está la BBDD.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

# Cargamos la configuración (para la contraseña de la BBDD, $DB_PASSWD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

initDBUser() {

  # Si no tenemos el rol main, terminamos
  # (puedes añadir otros con 'or . == "worker"')
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  # Decidimos la contraseña en base a las variables de entorno y
  # creamos el usuario
  set +x
  local passwd="${DB_PASSWD-$DB_PASS_ALTERNATIVE}"
  passwd=${passwd-notsecure}
  su postgres -c "psql -c \"CREATE USER cmsuser WITH PASSWORD '${passwd}';\""
  set -x
  su postgres -c "createdb --username=postgres --owner=cmsuser cmsdb"
  su postgres -c "psql --username=postgres --dbname=cmsdb --command='ALTER SCHEMA public OWNER TO cmsuser'"
  su postgres -c "psql --username=postgres --dbname=cmsdb --command='GRANT SELECT ON pg_largeobject TO cmsuser'"
}

initDBUser
