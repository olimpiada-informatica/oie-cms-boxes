#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Configura nginx para hacer accesibles los rankings configurados.
# Cambia el comportamiento de la URL raíz para que lleve a él.
#
# Solo lo hace si se tiene el rol ranking.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

# Cargamos la configuración (para el número y ruta de los rankings)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x   
fi

# Create First Admin user
publishRankings() {

  # Si no tenemos el rol rankingfrontend, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "rankingfrontend")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  # Construimos uno a uno
  numRankings=${NUM_RANKINGS-3}

  for c in $(seq 1 $numRankings); do
    VBLE=PATH_RANKING_$c
    PATH_URL=${!VBLE-ranking$c}

    if [ ! -z "$PATH_URL" ]; then
      publishRankingWeb.sh $c $PATH_URL
      # Damos un tiempo para que nginx se relance
      sleep 5
    fi
  done

  if [ "$numRankings" -gt 0 ]; then
    readonly ENDPOINTS_DIR="/etc/nginx/sites-available/cms-endpoints"
    cp "$ENDPOINTS_DIR/root.conf.rankingfrontend" "$ENDPOINTS_DIR/root.conf"
    service nginx restart
  fi

}

publishRankings
