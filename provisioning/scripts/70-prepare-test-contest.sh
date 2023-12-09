#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Crea (en main y ranking frontend) el directorio que tendrá la información del
# concurso de prueba y copia los datos de envíos que están en el home del
# usuario que monta la máquina (típicamente usuario vagrant)
#
# Además, en main, copia al mismo directorio los scripts para crear el
# concurso y simular los envíos.

# Cargamos la configuración (para saber si tenemos concurso de prueba)
if [ "$CONFIG_FILE" -a -f "$CONFIG_FILE" ]; then
   set +x
   source "$CONFIG_FILE"
   set -x
fi

if [ -z $CONCURSO_PRUEBA ]; then
  exit 0
fi

die() {
    echo $@ 2>&1
    exit 1
}

[ -z "$NODE_INFO" ] && die "No se indicó variable \$NODE_INFO"
[ ! -f "$NODE_INFO" ] && die "Fichero $NODE_INFO no encontrado"

prepareTestContest() {

  # Si no tenemos el rol main o ranking, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main" or . == "rankingfrontend")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  readonly user=${DEFAULT_USER-$(whoami)}

  mkdir /home/cms/concurso-prueba
  mv "/home/$user/datos-simulacro" /home/cms/concurso-prueba
  chown -R cms:cms /home/cms/concurso-prueba
}

installScripts() {

  # Si no tenemos el rol main, terminamos
  hasRole=$(cat "$NODE_INFO" | jq -r 'any(.roles[]; . == "main")')

  if [ "$hasRole" != "true" ]; then
    return
  fi

  readonly PROVISION_DIR=/home/vagrant/provision-files/scripts

  cp "$PROVISION_DIR/registerTestContest.sh" /home/cms/concurso-prueba
  cp "$PROVISION_DIR/simulateSubmissions.sh" /home/cms/concurso-prueba

  chown cms:cms /home/cms/concurso-prueba/*.sh
}

prepareTestContest
installScripts
