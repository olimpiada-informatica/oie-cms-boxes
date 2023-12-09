#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Cambia el fichero /etc/hosts para que la entrada con el nombre
# del nodo que apunta a 127.0.0.1 apunte a la IP "pública" del
# nodo. Es importante porque los distintos servicios utilizan
# esa configuración para determinar por qué interfaz de red
# escucharán las conexiones. Si se deja 127.0.0.1 los servicios
# no serán accesibles desde fuera.

FILE="/etc/hosts"
BACKUP=$FILE.backup

cp "$FILE" "$BACKUP";
if [ $? -ne 0 ]; then
   echo -e "--- --- --- Could not create backUp /etc/hosts. Terminating! --- --- ---";
   exit 1;
fi

> $FILE
while read LINE; do
   if [[ "$LINE" == *"$(hostname)"* ]]; then
      echo -ne "$NODE_IP\t" >> "$FILE";
      echo "$LINE" | cut -f2- >> "$FILE";
    else
        echo "$LINE" >> "$FILE";
    fi
done < $BACKUP

rm $BACKUP
