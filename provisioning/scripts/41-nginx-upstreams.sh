#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Copia los ficheros con los upstreams de nginx en base al tipo de nodo

readonly PROVISION_DIR=/home/vagrant/provision-files/nginx/upstreams
readonly TARGET_DIR=/etc/nginx/conf.d

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

function doIt() {
    
    # Si no tenemos un rol que requiera nginx, terminamos
    hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "adminfrontend" or . == "contestfrontend" or . == "rankingfrontend")')

    if [ "$hasRole" != "true" ]; then
        return
    fi

    # upstreams de todos los roles
    if [ -d "$PROVISION_DIR/all" ]; then
        cp "$PROVISION_DIR"/all/* "$TARGET_DIR"
    fi

    # upstreams específicos
    for rol in $(cat "$NODE_INFO" | jq -r '.roles[]' ); do

        if [ -d "$PROVISION_DIR/$rol" ]; then
            cp "$PROVISION_DIR/$rol"/* "$TARGET_DIR"
        fi
    done

}

doIt