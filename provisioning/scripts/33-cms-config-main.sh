#!/bin/bash -ex

# Añade en cms.conf entradas de servicios únicos del rol main,
# en concreto la configuración de su ProxyServer

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"


configContestWebServer() {

    # Si no tenemos el rol contest, terminamos
    hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

    if [ "$hasRole" != "true" ]; then
        return
    fi

    # Añadimos
    patchLocalConfigFile.sh \
        '.core_services.ProxyService[0]=["'$MAIN_NODE_NAME'",28600]'

    # Instalamos
    installLocalConfigFile.sh
}

configContestWebServer
