#!/bin/bash -ex

# Crea el usuario del sistema operativo 'cms' cuyo home tendrá todo
# lo relacionado con CMS

echo Creando usuario del sistema 'cms'

readonly userPassword=${OS_USER_PASSWORD-s3cr3t}

# Usuario
adduser --disabled-password \
        --gecos "Usuario del sistema para ajustar el comportamiento de CMS" \
        --shell /bin/bash \
        cms

# Contraseña
set +x
echo cms:$userPassword | chpasswd
set -x

# sudoer
usermod -aG sudo cms

# sudoer sin contraseña
echo "cms ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
