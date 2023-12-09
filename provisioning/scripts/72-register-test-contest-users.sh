#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Añade en CMS usuarios y equipos de prueba que se podrán usar
# para probar el login como usuario y/o para simular un concurso

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

registerContestants() {

  # Si no tenemos el rol main, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  cd /home/cms/concurso-prueba/datos-simulacro/usuarios
  registerUsers.sh users.json
  registerTeams.sh teams.json
}

registerContestants
