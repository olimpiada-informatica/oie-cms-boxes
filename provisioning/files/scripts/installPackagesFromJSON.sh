#/bin/bash
#

# Utilidad durante la construcción de las máquinas virtuales.
# Instala (con apt-get) los paquetes indicados en un .json (como
# prerequisites.json). El json se espera que sea un objeto con
# distintas entradas, cada una de ellas con un array con la lista
# de bloques de paquetes a instalar. Cada bloque tiene un texto
# explicativo (campo 'comment') y el array con los nombres de
# los paquetes.
#
# Va escribiendo los comentarios al ir lanzando las instalaciones.
#
# Recibe como parámetro el nombre del fichero .json y la entrada
# que contiene la lista de paquetes a instalar.
#
# Ejemplo:
#   $ installPackageFromJSON.sh prerequisites.json contestfrontend

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$1" ] && die "No se indicó fichero .json"
[ -z "$2" ] && die "No se indicó entrada dentro del .json"
[ ! -f "$1" ] && die "Fichero $1 no encontrado"
jsonFile="$1"
nodeName="$2"

# Si no existe esa entrada, terminamos.
[ -z "$(cat "$jsonFile" | jq -r '.'$nodeName' //empty | @base64' 2> /dev/null)" ] && die "Entrada $nodeName no existe"

# Iteramos e instalamos
for entry in $(cat "$jsonFile" | jq -r '.'$nodeName'[] | @base64' ); do
    # entry: cada uno de los lotes a instalar
    
    # Función "local" que escribe el campo pedido de la entrada $entry
    _getField() {
        echo ${entry} | base64 --decode | jq -r '.'${1}' // empty'
    }

    # Si está el campo packages
    if [ ! -z "$(_getField packages)" ]; then

        # Escribimos el comentario asociado y lista de paquetes
        echo "Intalando paquetes: "$(_getField "comment")" ("\
           $(echo ${entry} | base64 --decode | jq -r '.packages | join(" ")') \
           ")"

        # Instalamos
        echo ${entry} | \
        base64 --decode | \
        jq -r '.packages | join(" ")' | xargs apt-get install -y
    fi
done
