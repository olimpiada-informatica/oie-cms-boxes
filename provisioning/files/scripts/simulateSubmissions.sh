#/bin/bash
#
# Simula los envíos al concurso de prueba en una instalación nueva de CMS.
#
# Asume que el inicio del concurso está en el fichero .start, dejado
# por el script rgisterTestContest.sh. De no ser así, supone que el
# concurso no ha sido instalado y termina.
#
# OJO: se asume que la instalación de CMS es nueva; los envíos se harán
# al concurso 1 de CMS.

PROBLEM_FOLDER="/home/cms/concurso-prueba/problemas-concurso"

die() {
    echo $@ 2>&1
    exit 1
}

[ -f "$PROBLEM_FOLDER/.start" ] || die "Parece que el concurso no ha sido creado; al menos no encontramos el fichero $PROBLEM_FOLDER/.start con su momento de inicio. Ejecuta registerTestContest.sh"
[ -w "$PROBLEM_FOLDER" ] || die "Ejecuta el script con el usuario 'cms'"

start=$(cat "$PROBLEM_FOLDER/.start")

#start=$(date +%s)
#let start=start-12600
#let start=start/3600
#let start=start*3600

cd "/home/cms/concurso-prueba/datos-simulacro/"
addSubmissions.sh 1 "$PROBLEM_FOLDER" $start
