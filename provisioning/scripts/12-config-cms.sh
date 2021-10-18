#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Ajusta el cms.config y cms.ranking.conf con las contraseñas configuradas
# y con otras aleatorias creadas en el momento

# Cargamos la configuración (para la contraseña de la BBDD, $DB_PASSWD)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x   
fi

readonly user=${DEFAULT_USER-$(whoami)}
readonly AS_USER=${1-$user}
readonly SRCDIR=/home/$user/provision-files

# Generamos usuario/contraseña para el ranking server y la secret_key de
# comunicación entre servicios. Usando tres formas distintas de generar
# cadenas aleatorias (usar las tres veces date +%s podría generar
# las tres veces lo mismo).
set +x
RANKING_USER=$(date +%s | sha256sum | base64 | head -c 8 ; echo)
RANKING_PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c 32; echo;)
SECRET_KEY=$(python3 -c 'from cmscommon import crypto; print(crypto.get_hex_random_key())')
set -x

patchConfigFile() {

  local configFile="/home/$AS_USER/cms/config/cms.conf"
  local oldConfigFile="$configFile".old

  cp "$configFile" "$oldConfigFile"

  cat "$oldConfigFile" | jq $@ > $configFile

  rm "$oldConfigFile"
}

patchRankingConfigFile() {

  local configFile="/home/$AS_USER/cms/config/cms.ranking.conf"
  local oldConfigFile="$configFile".old

  cp "$configFile" "$oldConfigFile"

  cat "$oldConfigFile" | jq $@ > $configFile

  rm "$oldConfigFile"
}

initCMSConfig() {
  cd /home/${AS_USER}

  cp /home/${AS_USER}/cms/config/cms.conf{.sample,}

  set +x
  local pswd=${DB_PASSWD-notsecure}
  patchConfigFile '.rankings[0]="http://'$RANKING_USER':'$RANKING_PASS'@localhost:8890/"'
  patchConfigFile '.database="postgresql+psycopg2://cmsuser:'$pswd'@localhost:5432/cmsdb"'
  patchConfigFile '.secret_key="'$SECRET_KEY'"'
  patchConfigFile '.admin_num_proxies_used=1'
  set -x
}

initCMSRankingConfig() {
  cd /home/${AS_USER}

  cp /home/${AS_USER}/cms/config/cms.ranking.conf{.sample,}

  # Contraseñas del ranking
  set +x
  patchRankingConfigFile '.username="'$RANKING_USER'"'
  patchRankingConfigFile '.password="'$RANKING_PASS'"'
  set -x

  # Número de workers
  local numWorkers=${NUM_WORKERS-5}
  patchConfigFile 'del(.core_services.Worker['$numWorkers':])'

  # Añadimos varios shard en el Proxy Service para que podamos lanzarlo con systemctl
  # (el cmsProxyService@.service recibe el id del concurso que se aprovecha
  # para el shard)
  # DESACTIVADO: parece que el ProxyService no recibe correctamente las notificaciones
  # al puerto interno cuando no está en el shard 0 :-? Por tanto, no tiene
  # sentido tener más shards. Por tanto, el cmsProxyService@.service ya
  # no pasa un shard como parámetro tampoco).
  #for port in $(seq 28601 28610); do
  #  patchConfigFile '.core_services.ProxyService+=[["localhost",'$port']]'
  #done
}

installConfig() {
  cd /home/${AS_USER}/cms
  python3 prerequisites.py -y install
}

initCMSConfig
initCMSRankingConfig
installConfig
