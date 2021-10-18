#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Descarga, si así está configurado, el concurso de prueba desde
# GitHub

readonly CONTEST_URL="https://github.com/olimpiada-informatica/cms-ejemplo-concurso"
readonly CONTEST_BRANCH="master"

readonly user=${DEFAULT_USER-$(whoami)}

# Cargamos la configuración (para la contraseña de la BBDD, $DB_PASSWD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

if [ -z $CONCURSO_PRUEBA ]; then
  exit 0
fi

downloadContest () {

  readonly AS_USER=${1-$user}

  cd /home/${AS_USER}

  # Descargamos como usuario no administrador (no es importante, en realidad)
  su "$AS_USER" -c "git clone ${CONTEST_URL} --branch ${CONTEST_BRANCH}"
}

downloadContest "$@"
