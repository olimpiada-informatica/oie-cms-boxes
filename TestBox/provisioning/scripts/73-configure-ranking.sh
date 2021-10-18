#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Añadimos en el directorio del ranking las fotos de participantes
# y "banderas" de equipos


readonly user=${DEFAULT_USER-$(whoami)}
readonly SIM_DIR=/home/$user/datos-simulacro
readonly CONTESTDIR=/home/$user/cms-ejemplo-concurso


# Cargamos la configuración (para la contraseña de la BBDD, $DB_PASSWD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

if [ -z $CONCURSO_PRUEBA ]; then
  exit 0
fi

# Por último, añadimos las fotos en el directorio del ranking
addRankingImages.sh /var/local/lib/cms/ranking "$SIM_DIR/usuarios"
