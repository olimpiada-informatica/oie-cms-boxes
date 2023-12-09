#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Copia las descripciones de los distintos servicios de CMS
# en el directorio adecuado (/etc/systemd/system)
#
# Dependiendo del rol del nodo se copian unos u otros.

readonly PROVISION_DIR=/home/vagrant/provision-files/systemd
readonly TARGET_DIR=/etc/systemd/system

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

# Recargamos el servicio para que analice los nuevos ficheros
systemctl daemon-reload
