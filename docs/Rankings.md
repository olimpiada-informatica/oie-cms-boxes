# Rankings en CMS-OIE

El funcionamiento de los rankings en CMS es muy versátil, aunque esa
verstilidad tiene un precio: son difíciles de administrar. Nuestra
instalación de CMS facilita esa administración imponiendo una serie
de restricciones. Es importante conocer cómo funciona y qué opciones
hay disponibles para poder gestionarlos correctamente así como personalizarlos
para situaciones concretas.

## Qué es un ranking para CMS

En CMS los rankings son responsabilidad del *RankingWebServer*, un
servidor HTTP capaz de gestionar un único ranking. De esta forma si se
quieren tener varias clasificaciones se deberán lanzar varias instancias
del servidor, cada una escuchando en un puerto concreto. Posteriormente
se utilizará nginx para acceder a cada uno de ellos con rutas concretas.

Los servidores de rankings pueden separarse por completo del resto
de la instalación de CMS, tal y como se describe [aquí](https://cms.readthedocs.io/en/v1.4/RankingWebServer.html), de forma que se puede tener una máquina
específica fuera de la red interna del concurso publicando la clasificación
en directo "al mundo" sin poner en peligro el resto del sistema.

En CMS-OIE no se ha tenido tanto cuidado con esto y, tal y como
se describe [aquí](AFondo.md), la infraestructura de rankings
que utilizamos exige que éstos estén en la misma máquina que juega
el rol de ```main``` con la base de datos y otros servicios esenciales.

El *RankingWebServer* para funcionar necesita:

   - Que CMS se conecte con él periódicamente para enviarle los eventos
   que van teniendo lugar en el concurso para actualizar la clasificación.
   El servicio encargado de esos avisos es el *ProxyService* (que en
   nuestra instalación está en la máquina con rol ```main```).
   - Un fichero de configuración con el puerto en el que escuchar, así
   como las credenciales de acceso que el *ProxyService* utilizará para
   enviarle la información del concurso. Es importante mantener esas
   credenciales en secreto, claro, pues en caso contrario un atacante podría
   hacerse pasar por el *ProxyService* e informar de eventos incorrectos.
   - Un directorio local donde el servidor va guardando esa información
   recibida para poder servir las páginas. Ese directorio, además, puede
   incluir las fotos de los participantes y las banderas de los países
   a los que pertenecen.

Por lo tanto para tener un ranking en CMS necesitaremos:

   - Tener un directorio local gestionado por el servidor del ranking y
   un fichero de configuración que utilizará en el momento de lanzarse.
   - Lanzar el *RankingWebServer* en la máquina adecuada.
   - Configurar (en el cms.conf correspondiente) el *ProxyService* para
   que conozca la URL y credenciales de acceso al servidor para
   enviarle las notificaciones.

Para gestionar todo lo anterior cómodamente, CMS-OIE utiliza un esquema
fijo e instala unos scripts que facilitan el uso.

## Rankings en CMS-OIE

Los rankings en CMS-OIE se encuentran siempre en la misma máquina en la
que está la base de datos y servicios esenciales de CMS, especialmente
el *ProxyService* (más detalles sobre esto [aquí](AFondo.md)). La razón
de esta restricción es que los scripts de soporte deben trabajar tanto con
el directorio de datos de los rankings y su fichero de configuración
para lanzar/parar correctamente los *RankingWebServer* como con la
configuración del *ProxyService*. Si estuvieran en máquinas separadas
la configuración de los rankings implicaría tocar en todas ellas (obviamente
eso no significa que no sea posible; con algo de esfuerzo se puede tener
un ranking en una máquina distinta, pero hay que hacerlo de forma manual en
lugar de utilizar los scripts proporcionados).

Dependiendo de la configuración utilizada y el ```.env``` usado la
instalación tendrá más o menos rankings. En concreto, [TestBox](../TestBox/)
tendrá un único ranking (si se configuró concurso de prueba). Las otras
tendrán tantos rankings como se indicara en el ```.env``` siendo el
primero de ellos reservado para el concurso de prueba si se habilitó.

Desde el punto de vista de los scripts, los rankings configurados tienen
identificadores numéricos consecutivos. Durante la creación de la máquina
virtual, para cada ranking:

   - Se crea un fichero de configuración con credenciales elegidas
   aleatoriamente.
   - Se crea un directorio para albergar la información asociada.
   - Se habilita el lanzamiento del *RankingWebServer* correspondiente
   instruyéndolo para que utilice el fichero de configuración adecuado.
   - Se configura nginx para redirigir el tráfico a la ruta indicada
   en el ```.env``` (```/participante``` cableado en el caso de TestBox)
   al *RankingWebServer* asociado.

Por último en el directorio de datos asociado al ranking del concurso de
prueba, se copian los distintos logos y fotos de los participantes.

Tanto los ficheros de configuración como los directorios de datos se
encuentran en ```/home/cms/rankings```. Los directorios son ```rankingX```
y los ficheros de configuración ```cms.rankingX.conf``` (donde la X representa el
identificador del ranking).

La instalación crea los rankings pero *no habilita su actualización* por lo que
si se monta un concurso en el CMS y se hacen envíos, ninguno de los rankings
sufrirá cambios.

Para activar/desactivar los rankings existen tres scripts (los tres deben
ejecutarse como ```root```):

   - ```enableRankingUpdates.sh <id>```: habilita la actualización del
   ranking cuyo id se indica. Internamente lo que hace es configurar
   el *ProxyService* para que avise al *RankingWebServer* asociado.
   Las credenciales que utilizar las coge del fichero de configuración
   del ranking.
   - ```disableRankingUpdates.sh <id>```: deshabilita la actualización
   de un raking concreto.
   - ```disableAllRankingUpdates.sh```: deshabilita la actualización de
   todos los rankings.

Estos tres scripts son claves para conseguir emoción en competiciones de
varios concursos, congelando marcadores, permitiendo la existencia de
rankings separados de cada día y un ranking agregado común. Todo esto
está explicado [aquí](./RoadmapDeUnaCompeticion.md).

## Fotos, banderas y logo de los rankings

En las páginas de los rankings aparece a la izquierda el logo del
concurso y por cada participante la "bandera" del país al que pertenecen
(que en concursos como la OIE puede ser el logo de la regional de origen,
por ejemplo) y una foto.

Para conseguirlo, deben copiarse las imágenes a los directorios de datos
de todos los rankings. Lo mejor para eso (y para otras cosas)
es tener en ficheros .json la lista de participantes y la lista de
equipos/países, y tener las imágenes organizadas tal y como las esperan
los rankings. Haciéndolo de esta manera se puede utilizar el script
```addRankingImages.sh``` para añadir las imágenes a cada uno de los
rankings.

Un ejemplo de datos se puede encontrar en el directorio
```/home/cms/concurso-prueba/datos-simulacro/usuarios``` de
la máquina que tiene los rankings (siempre y cuando se haya configurado el
concurso de prueba). Hay una explicación más detallada sobre todo
esto en [el repositorio de GitHub asociado](https://github.com/olimpiada-informatica/cms-utils).

## Ranking en la URL raiz de la máquina

En algunas de las instalaciones se configura nginx para que la URL raíz de
la máquina lleve al primer ranking. El responsable de este funcionamiento
es el fichero ```/etc/nginx/sites-available/cms-endpoints/root.conf```. Cuando
la URL raíz lleva al ranking, el contenido del fichero será algo así:

```
# Acceso al primer ranking desde el dominio raíz.
location / {
    proxy_pass http://rws1/;
    include proxy_params;
    proxy_http_version 1.1;
    proxy_set_header Connection "";

    # Needs to be as large as the maximum allowed submission
    # and input lengths set in cms.conf.
    client_max_body_size 50M;
}
```

Si se desea que lleve a algún otro ranking, basta cambiar la línea
con el ```proxy_pass http://rws1/;``` y cambiar el 1 por el id del
ranking deseado. Tras eso, habrá que recargar nginx con
```system nginx restart```.

## Creando rankings nuevos

Si tras la creación de la máquina se quiere añadir algún ranking adicional
existen también scripts para hacerlo. Los pasos son:

   1. Ejecutar ```initRanking.sh <id>``` que crea un fichero de configuración
   con credenciales aleatorias y el directorio de datos del ranking
   cuyo id se indica. El id debe ser nuevo.
   2. Habilitar el  *RankingWebService* asociado ejecutando (como root)
   ```enableCMSService.sh cmsRankingWebServer@X.service``` donde el X
   será el identificador numérico del ranking.
   3. Ejecutar ```publishRankingWeb.sh <id> <ruta>``` que configura nginx
   para vincular la ruta indicada con el *RankingWebServer* asociado al id
   dado.

## Eliminando un ranking

Si en algún momento se quiere eliminar un ranking (es decir, dejar de hacerlo
público), se debe:

   1. Deshabilitar el *RankingWebService* asociado jecutando (como root)
   ```disableCMSService.sh cmsRankingWebServer@X.service``` donde el X
   será el identificador numérico del ranking.
   2. Ejecutar ```unpublishRankingWeb.sh <id>``` que borra la configuración
   de nginx asociada al ranking id.

El directorio de datos del ranking puede eliminarse también si se quiere,
o dejarlo para utilizarlo, llegado el momento, para otra clasificación
distinta reutilizando el id interno.
