#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Descarga los problemas del concurso de prueba, si se configuró
# que se quiere simular.

readonly CONTEST_URL="https://github.com/olimpiada-informatica/cms-ejemplo-concurso"
readonly CONTEST_BRANCH="master"

# Cargamos la configuración (para saber si tenemos concurso de prueba)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

if [ -z $CONCURSO_PRUEBA ]; then
  exit 0
fi

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

downloadContest() {

  # Si no tenemos el rol main, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  cd /home/cms/concurso-prueba

  # Descargamos como usuario no administrador (no es importante, en realidad)
  su cms -c "git clone ${CONTEST_URL} --branch ${CONTEST_BRANCH} problemas-concurso"
}

downloadContest
