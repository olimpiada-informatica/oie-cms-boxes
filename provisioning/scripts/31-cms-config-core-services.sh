#!/bin/bash -ex

# Configura los servicios básicos de la instalación de CMS

MAIN_NODE_NAME=${MAIN_NODE_NAME-main}

# Cargamos la configuración (para la contraseña de la BBDD, $DB_PASSWD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

# Decidimos la secret_key en base a las variables de entorno y la
# instalamos. Si no hay nada en las variables de entorno,
# creamos una aleatoria.
set +x
if [ -z $SECRET_KEY_ALTERNATIVE ]; then
  SECRET_KEY_ALTERNATIVE=$(python3 -c 'from cmscommon import crypto; print(crypto.get_hex_random_key())')
fi
SECRET_KEY="${SECRET_KEY-$SECRET_KEY_ALTERNATIVE}"
set -x

configCoreServices() {

    # Conexión con postgresql
    set +x
    local pswd="${DB_PASSWD-${DB_PASS_ALTERNATIVE-notsecure}}"
    patchLocalConfigFile.sh '.database="postgresql+psycopg2://cmsuser:'$pswd'@'$MAIN_NODE_NAME':5432/cmsdb"'
    patchLocalConfigFile.sh '.secret_key="'$SECRET_KEY'"'
    patchLocalConfigFile.sh '.admin_num_proxies_used=1'
    set -x

    # Nuestro ResourceService. No usamos el `hostname` sino
    # la variable de entorno que viene desde Vagrant para poner localhost
    # en las máquinas single node.
    # Se añade al principio de la posible lista de ResourceService's
    # (de ahí el |= y el +.), aunque en la práctica se podría añadir
    # también al final, porque acabamos de vaciar la lista en el script
    # anterior
    patchLocalConfigFile.sh \
        '.core_services.ResourceService|=[["'$NODE_NAME'",28000]]+.'
        
    # Servicios en el main que se configuran en todos los nodos
    # El LogService es al que van informan de logs para condensar todos
    # en el mismo sitio. El ResourceService del main no es necesario que
    # esté en todos los nodos pero los otros parece que sí.
    patchLocalConfigFile.sh \
        '.core_services.LogService[0]=["'$MAIN_NODE_NAME'",29000]'
    patchLocalConfigFile.sh \
        '.core_services.ScoringService[0]=["'$MAIN_NODE_NAME'",28500]'
    patchLocalConfigFile.sh \
        '.core_services.Checker[0]=["'$MAIN_NODE_NAME'",22000]'
    patchLocalConfigFile.sh \
        '.core_services.EvaluationService[0]=["'$MAIN_NODE_NAME'",25000]'
    # Servicio de impresión no soportado
#    patchLocalConfigFile.sh \
#        '.core_services.PrintingService[0]=["'$MAIN_NODE_NAME'",25123]'

    # Instalamos
    installLocalConfigFile.sh
}

configCoreServices
