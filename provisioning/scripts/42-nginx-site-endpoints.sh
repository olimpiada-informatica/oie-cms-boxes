#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Copia los ficheros con las distintas rutas/endpoints a las que
# queremos atender.
#
# Cada endpoint está separado en un fichero distinto; todos ellos
# se encuentran en el directorio $ENDPOINTS_DIR y se incluyen
# desde el fichero site-cms.conf general.
#
# De esta forma es fácil/cómodo añadir o quitar endpoints de rankings.

readonly PROVISION_DIR=/home/vagrant/provision-files/nginx/endpoints
readonly TARGET_DIR=/etc/nginx/sites-available
readonly ENDPOINTS_DIR="$TARGET_DIR/cms-endpoints"

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

    # Fichero general que incluye los específicos con cada endpoint
    cp "$PROVISION_DIR/site-cms.conf" "$TARGET_DIR"

    # Directorio con los ficheros "de inclusión" con los endpoints
    mkdir -p "$ENDPOINTS_DIR"

    # endpoints de todos los roles
    if [ -d "$PROVISION_DIR/all" ]; then
        cp "$PROVISION_DIR"/all/* "$ENDPOINTS_DIR"
    fi

    # endpoints específicos
    for rol in $(cat "$NODE_INFO" | jq -r '.roles[]' ); do

        if [ -d "$PROVISION_DIR/$rol" ]; then
            cp "$PROVISION_DIR/$rol"/* "$ENDPOINTS_DIR"
        fi
    done
}

doIt
