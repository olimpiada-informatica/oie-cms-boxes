Directorio con recursos comunes para la creación de las distintas
máquinas virtuales.

Tiene recursos de dos tipos: scripts y ficheros

# Scripts

Los scripts son ejecutados por Vagrant en el momento de
crear las máquinas virtuales. Se ejecutarán en orden alfabético
por nombre, mezclándolos con los scripts específicos que se encuentran
en el directorio con el mismo nombre de los directorios
de las máquinas virtuales.

# Ficheros

Son ficheros necesarios por los scripts anteriores (como
por ejemplo ficheros de configuración). Se copian al disco
duro de las máquinas virtuales antes de comenzar con la
ejecución.

Igual que en el caso de los scripts, cada máquina instalación
podrá tener otros recursos adicionales en sus
directorios específicos.
