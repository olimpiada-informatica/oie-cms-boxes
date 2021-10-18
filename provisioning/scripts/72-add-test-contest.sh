#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Importa el concurso de prueba en CMS así como los participantes
# Asume que es el primer concurso que se importa y que, por tanto,
# el id será el 1

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

# Seleccionamos la hora de inicio del concurso
# Será la hora entera más cercana a hace 3:30
# (los envíos que se harán será en las 3:30 iniciales del
# concurso)

# Si lo cambias, cambia 94-simulate-submissions.sh
start=$(date +%s)
let start=start-12600
let start=start/3600
let start=start*3600

# Importamos el concurso, durando 5 horas, para que con la máquina
# recién montada aún quede un tiempo para su finalización
addContest.sh "$CONTESTDIR" $start 18000

# Y registramos los participantes. Asumimos que es el concurso número 1...
cd "$SIM_DIR/usuarios"
registerParticipations.sh 1 users.json
