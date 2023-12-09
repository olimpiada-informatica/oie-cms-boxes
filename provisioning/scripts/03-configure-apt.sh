#!/bin/bash -ex

# "Configura" apt-get deshabilitando la instalación de paquetes recomendados
# o sugeridos y refresca el repositorio

# Disable installing recommended or suggested packages
cp /home/vagrant/provision-files/apt-get/no-recommend \
   /etc/apt/apt.conf.d/01-norecommend

# Refresh repository indexes
apt-get update -y
