#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Copia los scripts para administrar cómodamente CMS a /usr/local/bin
# para que estén en el path.

readonly OIE_CMS_UTILS="https://github.com/olimpiada-informatica/cms-utils"
readonly CMS_UTILS_BRANCH="master"

readonly user=${DEFAULT_USER-$(whoami)}

installCMSUtils() {

  readonly AS_USER=${1-$user}

  # Descargamos
  cd /home/${AS_USER}
  su "$AS_USER" -c "git clone ${OIE_CMS_UTILS} --branch ${CMS_UTILS_BRANCH}"

  # Copiamos scripts a ruta en el PATH
  cp cms-utils/*.sh /usr/local/bin
}

installCMSUtils "$@"
