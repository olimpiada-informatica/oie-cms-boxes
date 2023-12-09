#/bin/bash
#
# Registra en la copia vacía de CMS el concurso de prueba cuyos
# problemas están en el directorio 'problemas-concurso' y
# añade los participantes de datos-simulacro/usuarios.
#
# La duración del concurso serán 5 horas y el inicio se coloca
# de forma que el concurso ya ha empezado hace aproximadamente tres horas
# y media, de forma que si tras registrar el concurso se
# ejecuta simulateSubmissions.sh, éstas sucederán dentro del tiempo
# del concurso.
#
# OJO: se asume que la instalación de CMS está limpia en el momento
# de ejecutar el script. Los participantes se registrarán en el concurso 1
# de CMS (que no necesariamente será el recien creado si la copia de CMS no
# está limpia)

PROBLEM_FOLDER="/home/cms/concurso-prueba/problemas-concurso"

die() {
    echo $@ 2>&1
    exit 1
}

[ ! -f "$PROBLEM_FOLDER/.start" ] || die "Parece que ya has creado el concurso antes. Si no es así, borra el fichero $PROBLEM_FOLDER/.start"

[ -w "$PROBLEM_FOLDER" ] || die "Ejecuta el script con el usuario 'cms'"


start=$(date +%s)
let start=start-12600
let start=start/3600
let start=start*3600
echo $start > "$PROBLEM_FOLDER/.start"

# Importamos el concurso, durando 5 horas, para que con la máquina
# recién montada aún quede un tiempo para su finalización
addContest.sh /home/cms/concurso-prueba/problemas-concurso $start 18000

# Y registramos los participantes. Asumimos que es el concurso número 1...
cd "/home/cms/concurso-prueba/datos-simulacro/usuarios"
registerParticipations.sh 1 users.json
