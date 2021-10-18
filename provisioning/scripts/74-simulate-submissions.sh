#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Simula envíos al concurso de prueba al que asume con id=1.

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

# Copiado de 92-add-test-contest.sh
start=$(date +%s)
let start=start-12600
let start=start/3600
let start=start*3600

cd "$SIM_DIR"
addSubmissions.sh 1 "$CONTESTDIR" $start
