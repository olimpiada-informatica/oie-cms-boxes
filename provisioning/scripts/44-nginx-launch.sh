#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Tras crear los ficheros de configuración, elimina el site por
# defecto y activa el de cms y relanza nginx

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

    # Ajustamos la configuración de nginx    
    unlink /etc/nginx/sites-enabled/default
    ln -s /etc/nginx/sites-available/site-cms.conf /etc/nginx/sites-enabled/cms

    # Relanzamos
    service nginx restart
}

doIt
