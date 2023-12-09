#!/bin/bash
#
# USO: installLocalConfigFile.sh <orden para jq>
#
# Instala el fichero de configuración *LOCAL* de CMS en el directorio
# de instalación de CMS.
#
# Se entiende por fichero local el que está en la distribución de CMS
# descargada desde GitHub.
#
# El script lo que hace es simplemente copiarlo a /usr/local/etc
# que es desde donde lo leen los distintos servicios.
#
# El cambio no tendrá lugar hasta que esos servicios no se reinicien.
# Antes de hacerlo comprueba que el .json es correcto, para no sobreescribir
# con un fichero incorrecto.

die() {
    echo $@ 2>&1
    exit 1
}

installConfig() {

  # Sanity-check: el json tiene buena pinta
  local configFile="/home/cms/cmsCode/config/cms.conf"

  cat "$configFile" | jq -e . > /dev/null || die "Formato de fichero incorrecto. No instalamos"
  cp "$configFile" /usr/local/etc
}

installConfig
