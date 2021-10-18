#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Instala en la máquina los prerequisitos de CMS

# Adaptado de de https://github.com/cms-orbits/cms-boxes/tree/master/bulky/scripts

readonly user=${DEFAULT_USER-$(whoami)}
readonly SRCDIR=/home/$user/provision-files

installReqs () {
  # Disable installing recommended or suggested packages
  cp ${SRCDIR}/apt-get/no-recommend /etc/apt/apt.conf.d/01-norecommend

  # Refresh repository indexes
  apt-get update -y

  # Dependencias básicas de CMS y librerías
  # libcups2-dev se necesita aunque no se vaya a lanzar el servicio de impresión
  # pues el código de ptyon lo espera (falla la compilación si no).
  # Se incluye C y C++ para poder compilar "isolate"
  apt-get install -y python3.6 cgroup-lite libcap-dev zip libcups2-dev build-essential \
                     gcc g++ make

  # Dependencias para usar pip para instalar las dependencias de python
  apt-get install -y python3.6-dev libpq-dev libyaml-dev \
                     libffi-dev python3-pip

  # Base de datos
  apt-get install -y postgresql postgresql-client

  # Herramienta de instalación de aplicaciones en Python
  pip3 install setuptools

  # Lenguajes soportados en los concursos (además de Python y C/C++ ya instalados)
  apt-get install -y openjdk-11-jdk-headless

  # nginx que hará de proxy para acceder a rutas "humanas"
  apt-get install -y nginx

  # jq para manejar los ficheros .json de configuración
  apt-get install -y jq

  # Actualizamos pip
  #pip3 install pip --upgrade

  # Ponemos la zona horaria en España peninsular
  timedatectl set-timezone Europe/Madrid

  # Documentación de los lenguajes anteriores
  #apt-get install -y stl-manual cppreference-doc-en-html

  # Printing service
  # apt-get install -y libcups2-dev a2ps texlive-latex

  # Base dependencies and libs
  #apt-get install -y  build-essential gettext python2.7 python-dev \
  #                    iso-codes shared-mime-info cgroup-lite stl-manual \
  #                    python-pip libpq-dev libyaml-dev libffi-dev libcups2-dev \
  #                    libcap-dev

  # Contest Languages
  #apt-get install -y  openjdk-8-jre openjdk-8-jdk gcj-jdk \
  #                    php7.0-cli php7.0-fpm fpc \
  #                    haskell-platform rustc mono-mcs

  # Update pip (sería pip3)
  #pip install --force-reinstall -U setuptools
  #pip install --force-reinstall -U pip

  # Optional: HTTP proxy, database management UI
  #apt-get install -y nginx phppgadmin

}

installReqs "$@"
