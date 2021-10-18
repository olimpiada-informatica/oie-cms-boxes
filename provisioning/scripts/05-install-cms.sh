#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Instala CMS desde la copia local

readonly user=${DEFAULT_USER-$(whoami)}

installCMS () {

  readonly AS_USER=${1-$user}

  # Ejecutamos el script de prerequisitos. Crea el grupo cms,
  # compila "isolate" para ejecución segura y lo instala en
  # /usr/local/bin y /usr/local/etc
  # Copia otros ficheros necesarios en /usr/local/etc y /var/local
  # Con -y se salta las confirmaciones
  cd /home/${AS_USER}/cms
  python3 prerequisites.py -y install

  # Instalamos las librerías necesarias de Python usando pip3
  pip3 install -r requirements.txt
  python3 setup.py install
}

installCMS "$@"
