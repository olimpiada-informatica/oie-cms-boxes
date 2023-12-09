#!/bin/bash
#
# USO: initRanking.sh <id>
#
# Inicializa un nuevo ranking dado su id numérico:
#
#   - Crea el directorio donde el RankingServer guadará los datos.
#   - Crea el fichero de credenciales de comunicación entre ProxyServer
# y RankingServer con valores aleatorios.
#
# El id se espera que sea numérico. Si ya existe un ranking con ese id,
# no tene efecto.
#

readonly CMS_CONFIG_FOLDER="/home/cms/cmsCode/config"
readonly ROOT_TARGET_FOLDER="/home/cms/rankings"

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$1" ] && die "No se indicó el identificador del ranking"

RANKING_ID="$1"
TARGET_FOLDER="$ROOT_TARGET_FOLDER/ranking$RANKING_ID"
CONFIG_FILE="$ROOT_TARGET_FOLDER/cms.ranking$RANKING_ID.conf"

[ -n "$RANKING_ID" ] && [ "$RANKING_ID" -eq "$RANKING_ID" ] 2>/dev/null
[ $? -ne 0 ] && die "El id del ranking debe ser un número"
[ "$RANKING_ID" -gt 0 ] || die "El id debe ser positivo"
[ ! -d "$TARGET_FOLDER" ] || die "Parece que el ranking $RANKING_ID ya existe. Se ha encontrado el directorio $TARGET_FOLDER"
[ ! -f "$CONFIG_FILE" ] || die "Parece que el ranking $RANKING_ID ya existe. Se ha encontrado el fichero $CONFIG_FILE"
[ -w "$ROOT_TARGET_FOLDER" ] || die "Ejecuta el script como root o con el usuario 'cms'"

patchConfigFile() {

  local configFile="$1"
  local newConfigFile="$configFile".new
  
  cat "$configFile" | jq $2 > $newConfigFile || die "Error al parchear el fichero de configuración del ranking"
  mv "$newConfigFile" "$configFile"
}

createRanking() {

  local num=$1
  local port=$(echo 8890+$num-1 | bc)

  # Creamos el directorio y fichero de configuración
  mkdir -p "$TARGET_FOLDER"
  cp /home/cms/cmsCode/config/cms.ranking.conf.sample "$CONFIG_FILE"

  # Inventamos contraseñas
  local RANKING_USER=$(date +%s%N | sha256sum | base64 | head -c 8 ; echo)
  local RANKING_PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c 32; echo;)

  # Las establecemos en el fichero de configuración
  patchConfigFile "$CONFIG_FILE" '.username="'$RANKING_USER'"'
  patchConfigFile "$CONFIG_FILE" '.password="'$RANKING_PASS'"'
  patchConfigFile "$CONFIG_FILE" '.http_port='$port
  patchConfigFile "$CONFIG_FILE" '.lib_dir="'$TARGET_FOLDER'"'

  # Aseguramos permisos del usuario cms
  chown cms:cms "$CONFIG_FILE"
  chown cms:cms "$TARGET_FOLDER"
}

createRanking "$RANKING_ID"
