#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Inicializa el/los rankings, creando los directorios donde irán los
# datos y generando los ficheros de configuración.
#
# Solo lo hace si se tiene el rol ranking.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

# Cargamos la configuración (para el número de rankings)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x   
fi

# Create First Admin user
initRankings() {

  # Si no tenemos el rol rankingfrontend, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "rankingfrontend")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  # Creamos el directorio raíz
  su cms -c "mkdir /home/cms/rankings"

  # Construimos uno a uno
  numRankings=${NUM_RANKINGS-3}

  for c in $(seq 1 $numRankings); do
    initRanking.sh $c
  done
}

initRankings
