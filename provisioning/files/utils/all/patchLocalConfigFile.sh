#!/bin/bash
#
# USO: patchLocalConfigFile.sh <orden para jq>
#
# Cambia el fichero de configuración *LOCAL* de CMS ejecutando sobre él
# la orden de jq que recibe como parámetro.
#
# Se entiende por fichero local el que está en la distribución de CMS
# descargada desde GitHub.
#
# El fichero parcheado no tendrá efecto hasta que no:
#    - Se "instale" (installLocalConfigFile.sh) en el directorio
# de instalación.
#    - Se reinicien los servicios correspondientes.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$1" ] && die "No se indicó el parche a aplicar (formato jq)"

patchConfigFile() {

  local configFile="/home/cms/cmsCode/config/cms.conf"
  local newConfigFile="$configFile".new

  cat "$configFile" | jq $@ > $newConfigFile || die "Error al aplicar el parche"

  mv "$newConfigFile" "$configFile"
}

patchConfigFile $@
