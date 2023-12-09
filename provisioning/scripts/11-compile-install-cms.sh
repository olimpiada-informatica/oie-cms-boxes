#!/bin/bash -ex

# Compila el CMS descargado de GitHub y lo instala

installCMS () {

  # Ejecutamos el script de prerequisitos. Crea el usuario cmsuser:cmsuser
  # Añade el usuario actual a cmsuser.
  # Compila "isolate" para ejecución segura y lo instala en
  # /usr/local/bin y /usr/local/etc
  # Copia otros ficheros necesarios en /usr/local/etc y /var/local
  # Con -y se salta las confirmaciones
  # Se debe hacer con el usuario cms, que tiene permiso de escritura
  # en su home, pero como root (sudo).
  cd /home/cms/cmsCode
  su cms -c "sudo python3 prerequisites.py -y install"

  # Instalamos las librerías necesarias de Python usando pip3
  pip3 install -r requirements.txt
  python3 setup.py install
}

installCMS "$@"
