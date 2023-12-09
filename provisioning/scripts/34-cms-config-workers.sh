#!/bin/bash -ex

# Añade la entrada Workers en cms.conf si tenemos ese rol y también
# si tenemos el rol main, pues en caso de configuraciones MultiNodo,
# el main también debe conocer la lista de workers disponibles
# (no está muy claro por qué).

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

# Cargamos la configuración (para $NUM_WORKERS)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

configWorkers() {

    # Si no tenemos el rol worker o main, terminamos
    hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "worker" or . == "main")')

    if [ "$hasRole" != "true" ]; then
        return
    fi

    # Añadimos uno a uno los workers
    for port in $(seq 26000 $(( 26000 + $NUM_WORKERS - 1)) ); do 
        patchLocalConfigFile.sh '.core_services.Worker+=[["'$WORKER_NODE_NAME'",'$port']]'
    done    

    # Instalamos
    installLocalConfigFile.sh
}

configWorkers
