#!/bin/bash
#
# USO: getActiveContest.sh
#
# Mirando qué procesos hay lanzados en la máquina, determina qué
# concurso es el que está activado en CMS, entendiendo por concurso
# activado aquel con el que ha sido lanzado el cmsResourceManager,
# y que determina:
#
#    - A qué concurso pueden hacer login los participantes
#    - A qué concurso atienden los workers
#    - De qué concurso se notifica el progreso a los rankings
#    - ...
#
# Escribe por la salida estandar el número/id del concurso o
# ALL si son todos

# Explicación: el ps aux lista los procesos, entre los que está
# el cmsResourceService. Nos quedamos con él lo que dará una
# línea del tipo:
#
#root     24308  0.2  1.4 306476 59160 ?        Sl   18:14   0:01 /usr/bin/python3 /usr/local/bin/cmsResourceService -a 1
#
# que contiene la llamada (y parámetros) con los que se lanzó el
# cmsResourceService. El valor detrás del -a es el id del concurso (o
# "ALL". Con sed se escribe ("sustituir el grupo 1 de la expresión
# s/^.* \-a \(.*\) por el grupo 1 (= borrar todo lo demás), y luego escribirlo
# (p)")

ps aux | grep python | grep cmsResourceService | sed -n "s/^.* \-a \(.*\)/\1/p"
