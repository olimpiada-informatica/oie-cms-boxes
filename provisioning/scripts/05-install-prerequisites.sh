#!/bin/bash -ex

# Instala los prerequisitos de CMS asociados a la máquina.
# La lista concreta dependerá de la funcionalidad para la que se
# ha destinado la máquina, que viene en el fichero .json cuya ruta
# se pasa en $NODE_INFO

readonly PROVISION_DIR=/home/vagrant/provision-files

# Lista de prerequisitos por cada rol/funcionalidad de la máquina.
readonly PREREQUISITES_FILE="$PROVISION_DIR"/prerequisites.json

# Utilidad que hace el trabajo..
readonly INSTALL_SCRIPT="$PROVISION_DIR"/scripts/installPackagesFromJSON.sh

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"


# Prerequisitos de todos los roles
$INSTALL_SCRIPT $PREREQUISITES_FILE all

# Herramienta de instalación de aplicaciones en Python
#pip3 install setuptools==58.4.0
pip3 install setuptools

# Prerequisitos específicos
for rol in $(cat "$NODE_INFO" | jq -r '.roles[]' ); do
    
    $INSTALL_SCRIPT $PREREQUISITES_FILE $rol

done
