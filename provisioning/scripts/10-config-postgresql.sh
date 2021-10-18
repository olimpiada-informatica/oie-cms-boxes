#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Adaptado de de https://github.com/cms-orbits/cms-boxes/tree/master/bulky/scripts

# Configuramos postgresql (usuario de la BBDD)

# Cargamos la configuración (para la contraseña de la BBDD, $DB_PASSWD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi


readonly AS_USER=${1-postgres}
readonly user=${DEFAULT_USER-$(whoami)}
readonly SRCDIR=/home/$user/provision-files

initDBUser() {
  local pswd=${1-notsecure}
  su "$AS_USER" -c "psql -c \"CREATE USER cmsuser WITH PASSWORD '${pswd}';\""
  su "$AS_USER" -c "createdb --username=postgres --owner=cmsuser cmsdb"
  su "$AS_USER" -c "psql --username=postgres --dbname=cmsdb --command='ALTER SCHEMA public OWNER TO cmsuser'"
  su "$AS_USER" -c "psql --username=postgres --dbname=cmsdb --command='GRANT SELECT ON pg_largeobject TO cmsuser'"
}

enableRemoteConnection () {
  # Moving reference files
  mv /etc/postgresql/9.5/main/postgresql.conf{,.back}
  mv /etc/postgresql/9.5/main/pg_hba.conf{,.back}

  # Provision our postgresql configurations
  cp ${SRCDIR}/postgresql/* /etc/postgresql/9.5/main
  chown -R postgres:postgres /etc/postgresql/9.5/main

  # Restart service
  systemctl restart postgresql
}

initDBUser "$DB_PASSWD"
#enableRemoteConnection
