#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Añade en el ranking1 las imágenes de los usuarios y equipos que
# se utilizarán en el concurso de prueba.
#
# Solo si eres rankingfrontend

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

initRanking() {

  # Si no tenemos el rol rankigfrontend, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "rankingfrontend")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  addRankingImages.sh /home/cms/rankings/ranking1 "/home/cms/concurso-prueba/datos-simulacro/usuarios"

}

initRanking
