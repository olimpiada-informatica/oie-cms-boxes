#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Copia los scripts para administrar cómodamente CMS a /usr/local/bin
# para que estén en el path. Sólo lo hace en las máquinas en donde
# está la BBDD (nodo 'main') pues es donde querremos/podremos ejecutarlos.

readonly OIE_CMS_UTILS="https://github.com/olimpiada-informatica/cms-utils"
readonly CMS_UTILS_BRANCH="master"

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

installCMSUtils() {

  # Si no tenemos el rol main, terminamos
  # (puedes añadir otros con 'or . == "worker"')
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  # Descargamos
  cd /home/cms
  su cms -c "git clone ${OIE_CMS_UTILS} --branch ${CMS_UTILS_BRANCH}"

  # Copiamos scripts a ruta en el PATH
  cp cms-utils/*.sh /usr/local/bin

  # Y borramos lo descargado
  rm -rf /home/cms/cms-utils
}

installCMSUtils "$@"
