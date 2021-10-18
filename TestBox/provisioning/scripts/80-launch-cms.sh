#!/bin/bash -ex
# -e: termina si algún pipeline falla
# -x: escribe los comandos y argumentos según los va ejecutando

# Lanzamos CMS por primera vez (el resto de veces se
# lanzará automáticamente, pues se instala como servicio)

# Start Admin, Ranking and Log services
systemctl start cms@AdminWebServer.service cms@RankingWebServer.service cms@LogService.service

# Start the other services (ex: Evaluation, Proxy, Scoring, Worker and Checker)
systemctl start cmsResourceManager.service cmsProxyService@1.service
