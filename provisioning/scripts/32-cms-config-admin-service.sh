#!/bin/bash -ex

# Añade la entrada AdminWebServer en cms.conf si tenemos ese rol

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"


configAdminWebServer() {

    # Si no tenemos el rol admin, terminamos
    hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "adminfrontend")')

    if [ "$hasRole" != "true" ]; then
        return
    fi

    # Añadimos
    patchLocalConfigFile.sh \
        '.core_services.AdminWebServer+=[["'$ADMIN_NODE_NAME'",21100]]'

    # Instalamos
    installLocalConfigFile.sh
}

configAdminWebServer
