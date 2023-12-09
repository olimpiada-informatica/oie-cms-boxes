#!/bin/bash -ex

# Modifica la configuración del usuario cms para que el sudo
# requiera contraseña.
# Durante el provisioning se permitió para facilitar los
# scripts.

echo Eliminando la posibilidad de sudo sin contraseña al usuario 'cms'

grep -v "cms ALL" /etc/sudoers | sponge /etc/sudoers
