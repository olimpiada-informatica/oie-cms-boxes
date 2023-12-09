#!/bin/bash
#
# USO: unpublishRankingWeb.sh <id>
#
# Configura nginx para eliminar el endpoint con el ranking indicado.
# 
# Ejemplo:
#
#   $ unpublishRankingWeb.sh 2
#
# Para hacerlo, elimina el upstream rwsID y su site.
#

readonly SITE_FOLDER="/etc/nginx/sites-available/cms-endpoints"
readonly UPSTREAMS_FOLDER="/etc/nginx/conf.d"

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$1" ] && die "No se indicó el identificador del ranking"

RANKING_ID="$1"

RANKING_UPSTREAM_FILE="$UPSTREAMS_FOLDER/rws$RANKING_ID.conf"
RANKING_SITE_FILE="$SITE_FOLDER/ranking$RANKING_ID.conf"

[ -n "$RANKING_ID" ] && [ "$RANKING_ID" -eq "$RANKING_ID" ] 2>/dev/null
[ $? -ne 0 ] && die "El id del ranking debe ser un número"
[ "$RANKING_ID" -gt 0 ] || die "El id debe ser positivo"

rootOrDie() {
	 if [[ $EUID -ne 0 ]]; then
		  echo Debes ser root para ejecutar este comando 1>&2
		  exit 1
	 fi
}

unpublishRanking() {

  # upstream
  rm $RANKING_UPSTREAM_FILE

  # site
  rm $RANKING_SITE_FILE

  # recargamos nginx
  service nginx restart
}

rootOrDie
unpublishRanking
