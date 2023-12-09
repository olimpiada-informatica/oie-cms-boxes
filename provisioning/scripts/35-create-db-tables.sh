#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Crea la BBDD de CMS y sus tablas. Se debe hacer tras tener
# configurado CMS para que la herramienta que se utiliza sepa
# dónde encontrar la base de datos.
# Se hace únicamente si tenemos el rol main, pues es donde está la BBDD.

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

createDB() {

  # Si no tenemos el rol main, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  # Llamamos a la utilidad de CMS
  cmsInitDB
}

createDB
