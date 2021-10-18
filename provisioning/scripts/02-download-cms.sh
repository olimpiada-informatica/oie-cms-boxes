#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Descarga la versión de CMS de la OIE alojada en Github

readonly OIE_CMS="https://github.com/olimpiada-informatica/cms"
readonly CMS_BRANCH="oie-2022"

readonly user=${DEFAULT_USER-$(whoami)}

downloadCMS () {

  readonly AS_USER=${1-$user}

  cd /home/${AS_USER}

  # Descargamos y extraemos la Release de CMS (incluyendo submódulos, de ahí el --recursive)
  # Lo hacemos como un usuario /no/ administrador (si no, la compilación de "isolate" fallaría)
  su "$AS_USER" -c "git clone ${OIE_CMS} --recursive --branch ${CMS_BRANCH}"
}

downloadCMS "$@"
