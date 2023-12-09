#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Copia el fichero básico de nginx para CMS, nginx.conf

readonly PROVISION_DIR=/home/vagrant/provision-files/nginx
readonly TARGET_DIR=/etc/nginx

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

    cp "$PROVISION_DIR/nginx.conf" "$TARGET_DIR"
}

doIt
