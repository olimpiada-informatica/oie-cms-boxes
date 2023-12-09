#!/bin/bash -ex

# Habilita las conexiones a postgresql remotamente. Tras hacerlo, relanza
# el servicio

enableRemoteConnection () {

  # Escuchamos desde cualquier sitio
  echo "listen_addresses = '*'" >> /etc/postgresql/10/main/postgresql.conf

  # Aceptamos conexiones de cualquier sitio
  printf "host\tcmsdb\tcmsuser\tall\tmd5" >> /etc/postgresql/10/main/pg_hba.conf 

  # Restart service
  systemctl restart postgresql
}

enableRemoteConnection
