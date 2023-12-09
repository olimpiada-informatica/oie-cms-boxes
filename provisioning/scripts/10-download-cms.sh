#!/bin/bash -ex

# Descarga la versión de CMS de la OIE alojada en Github en el directorio
# del usuario cms

readonly OIE_CMS="https://github.com/olimpiada-informatica/cms"
readonly CMS_BRANCH="oie-2024"

# Desde el directorio home del usuario...
su cms -c "mkdir -p /home/cms/cmsCode"
cd /home/cms/cmsCode

# ...descargamos y extraemos la Release de CMS (incluyendo submódulos,
# de ahí el --recursive)
# Lo hacemos como un usuario /no/ administrador (si no, la compilación de
# "isolate" fallaría)
su cms -c "git clone ${OIE_CMS} --recursive --branch ${CMS_BRANCH} ."
