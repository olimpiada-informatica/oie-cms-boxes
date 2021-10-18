#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Añade en CMS usuarios y equipos de prueba que se podrán usar
# para probar el login como usuario y/o para simular un concurso

readonly user=${DEFAULT_USER-$(whoami)}
readonly SRCDIR=/home/$user/datos-simulacro

# Cargamos la configuración (para la contraseña de la BBDD, $DB_PASSWD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

if [ -z $CONCURSO_PRUEBA ]; then
  exit 0
fi

# Registramos los usuarios y equipos en el sistema
cd "$SRCDIR/usuarios"
registerUsers.sh users.json
registerTeams.sh teams.json
