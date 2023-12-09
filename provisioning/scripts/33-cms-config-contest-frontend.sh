#!/bin/bash -ex

# Añade la entrada ContestWebServer en cms.conf si tenemos ese rol

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"


configContestWebServer() {

    # Si no tenemos el rol contest, terminamos
    hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "contestfrontend")')

    if [ "$hasRole" != "true" ]; then
        return
    fi

    # Añadimos
    patchLocalConfigFile.sh \
        '.core_services.ContestWebServer+=[["'$CONTEST_NODE_NAME'",21000]]'

    # Instalamos
    installLocalConfigFile.sh
}

configContestWebServer
