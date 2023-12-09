#!/bin/bash -ex

# Añade en la lista de ResourceService del cms.conf (en el que ya debería
# estar referenciado el local por scripts compartidos por todos
# los boxes, 31-cms-config-core-services los ResourceServices de los demás
# nodos (main, worker, contestfrontend). Si no estuvieran todos registrados
# no saldrían en el interfaz web.

addAllResourceServices () {

    # Añadimos
    patchLocalConfigFile.sh \
        '.core_services.ResourceService+=[["'$MAIN_NODE_NAME'",28000]]'
    patchLocalConfigFile.sh \
        '.core_services.ResourceService+=[["'$CONTEST_NODE_NAME'",28000]]'
    patchLocalConfigFile.sh \
        '.core_services.ResourceService+=[["'$WORKER_NODE_NAME'",28000]]'

    # Instalamos
    installLocalConfigFile.sh
}

addAllResourceServices
