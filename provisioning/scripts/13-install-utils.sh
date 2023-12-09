#!/bin/bash -ex

# Copia otros scripts útiles a /usr/local/bin para que estén en el path.
# Esos scripts son distintos de los de GitHub instalados en el paso
# anterior pues son bastante específicos de las máquinas construidas
# aquí y son de dudosa utilidad para otras instalaciones de CMS
# distintas a la nuestra.
#
# Dependiendo del rol de la máquina, copia unos u otros

readonly PROVISION_DIR=/home/vagrant/provision-files/utils
readonly TARGET_DIR=/usr/local/bin

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

# Prerequisitos de todos los roles
cp "$PROVISION_DIR"/all/* "$TARGET_DIR"

# Prerequisitos específicos
for rol in $(cat "$NODE_INFO" | jq -r '.roles[]' ); do

    if [ -d "$PROVISION_DIR/$rol" ]; then
        cp "$PROVISION_DIR/$rol"/* "$TARGET_DIR"
    fi
done
