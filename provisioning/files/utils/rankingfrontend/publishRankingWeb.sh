#!/bin/bash
#
# USO: publishRankingWeb.sh <id> <path>
#
# Configura nginx para hacer visible el endpoint con el ranking indicado.
# 
# Ejemplo:
#
#   $ publishRankingWeb.sh 2 /oie-dia1
#
# Para hacerlo, instala el upstream rwsID y añade el site.
#

readonly SITE_FOLDER="/etc/nginx/sites-available/cms-endpoints"
readonly UPSTREAMS_FOLDER="/etc/nginx/conf.d"

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$1" ] && die "No se indicó el identificador del ranking"
[ -z "$2" ] && die "No se indicó la ruta del endpoint del ranking"

RANKING_ID="$1"
RANKING_PATH="$2"

RANKING_UPSTREAM_FILE="$UPSTREAMS_FOLDER/rws$RANKING_ID.conf"
RANKING_SITE_FILE="$SITE_FOLDER/ranking$RANKING_ID.conf"

[ -n "$RANKING_ID" ] && [ "$RANKING_ID" -eq "$RANKING_ID" ] 2>/dev/null
[ $? -ne 0 ] && die "El id del ranking debe ser un número"
[ "$RANKING_ID" -gt 0 ] || die "El id debe ser positivo"
[ ! -f "$RANKING_UPSTREAM_FILE" ] || die "Parece que el ranking $RANKING_ID ya está publicado. Se ha encontrado el fichero $RANKING_UPSTREAM_FILE"
[ ! -f "$RANKING_SITE_FILE" ] || die "Parece que el ranking $RANKING_ID ya está publicado. Se ha encontrado el fichero $RANKING_SITE_FILE"

rootOrDie() {
	 if [[ $EUID -ne 0 ]]; then
		  echo Debes ser root para ejecutar este comando 1>&2
		  exit 1
	 fi
}

publishRanking() {

  # upstream
  < $UPSTREAMS_FOLDER/rws.template \
    sed s/rwsID/rws$RANKING_ID/ |
    sed s/8890/$(echo 8890+$RANKING_ID-1 | bc)/ > $RANKING_UPSTREAM_FILE

  # site
  < $SITE_FOLDER/ranking.template \
    sed s+/RANKING_PATH+$RANKING_PATH+ |
    sed s+rwsID+rws$RANKING_ID+ >  $RANKING_SITE_FILE

  # recargamos nginx
  service nginx restart
}

rootOrDie
publishRanking
