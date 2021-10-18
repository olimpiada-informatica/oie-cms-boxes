#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Adaptado de de https://github.com/cms-orbits/cms-boxes/tree/master/bulky/scripts

# Copia los ficheros de configuración de nginx y relanza

readonly user=${DEFAULT_USER-$(whoami)}
readonly SRCDIR=/home/$user/provision-files

cp ${SRCDIR}/nginx/nginx.conf /etc/nginx
cp ${SRCDIR}/nginx/upstreams-cms.conf /etc/nginx/conf.d
cp ${SRCDIR}/nginx/site-cms.conf /etc/nginx/sites-available

# Disable default site and enable CMS ones
unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/site-cms.conf /etc/nginx/sites-enabled/cms

service nginx restart
