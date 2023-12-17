# CMS-OIE

Este documento explica con cierto detalle las decisiones que se han
tomado en la instalación de CMS propuesta. Si la instalación se va a utilizar
en la organización de algún concurso es importante que al menos uno
de los responsables de esa organización conozca estos detalles para, al menos:

   - Poder ajustar la instalación a las necesidades concretas de la sede.
   - Poder resolver los distintos problemas que puedan surgir durante
   el concurso.

También es aconsejable que algún responsable conozca
[la documentación de CMS](https://cms.readthedocs.io/en/v1.4/index.html).

## Ideas generales

CMS está dividido en [distintos servicios](https://cms.readthedocs.io/en/v1.4/Introduction.html#services)
que deben lanzarse por separado en un único servidor o en varios.

En base a esos servicios, la instalación de CMS-OIE distingue distintos
tipos de "roles" que puede jugar una máquina virtual (esta división no
viene impuesta por CMS; de hecho se podría incluso separar aún en más roles):

   - ```main```: este rol es jugado por la máquina que tiene la instancia
   de la base de datos (CMS en realidad permite que la BBDD esté incluso
   distribuida en varias máquinas), el servicio de Log centralizado y
   otros servicios como el *Checker*, *EvaluationService*, *ScoringService* y
   *ProxyService*.
   - ```rankingfrontend```: este rol es jugado por la máquina que tiene
   las páginas de los rankings, es decir, tiene lanzada una o más instancias
   del *RankingWebServer*. Los scripts de soporte de CMS-OIE funcionan
   asumiendo que tanto el rol ```main``` como el ```rankingfrontend```
   son jugados por la misma máquina. Esto es así porque para configurar
   rankings deben ajustarse servicios tanto de los *RankingWebServer* como
   del *ProxyService*.
   - ```worker```: este rol es jugado por aquella máquina que tiene uno
   o más procesos responsables de ejecutar los envíos en un entorno controlado.
   En otros jueces distintos a CMS es lo que se conoce como *judgehosts* o
   simplemente "jueces". Únicamente si se tiene este rol es necesario
   tener instalados los compiladores de todos los lenguajes admitidos
   en el concurso.
   - ```adminfrontend```: aloja el *AdminWebServer* con la página de
   administración utilizada por los administradores y jueces humanos.
   - ```contestfrontend```: con el *ContestWebServer* que monta la página
   utilizada por los participantes. En la máquina con este rol conviene tener
   instalada la documentación de C++ para que en la web de CMS se pueda
   navegar por ella.

En las máquinas responsables de páginas (ranking, administración y
participantes) se instala un nginx que redirige el tráfico que llega
al puerto 80 de la máquina hacia los servicios concretos. La instalación
de CMS-OIE se encarga también de esa configuración.

Sobre estos roles es importante entender que:

   - Tanto TestBox como SingleNode crean una única máquina que juega todos
   los roles.
   - La instalación MultiNode requiere cuatro máquinas. La que llamamos
   máquina *main* juega los roles ```main``` y ```rankingfrontend```, y
   existe además una máquina para cada uno de los roles restantes.

## CMS y su fichero de configuración

Todas las máquinas virtuales creadas tienen un usuario ```cms``` cuya
contraseña se especifica en el ```.env``` correspondiente. Dentro
del *home* de ese usuario ```/home/cms``` existe un directorio
```cmsCode``` con el código del CMS descargado de
[https://github.com/olimpiada-informatica/cms](GitHub) durante
la instalación.

Los distintos scripts que ejecuta Vagrant durante el *provisioning*
compilan CMS y lo instalan en el sistema. Además, configuran y lanzan
los servicios correspondientes en base al tipo de rol que juega la
máquina concreta. Todos esos servicios que se lanzan utilizan el
mismo fichero de configuración, ```/usr/local/etc/cms.conf```. El fichero
es un JSON con distintos atributos, algunos de ellos comunes en
todas las máquinas (típicamente credenciales de la base de datos);
de hecho esa parte común es la culpable de que en las
instalaciones de multi-nodo **no se pueda** crear cada una de las máquinas
por separado (ejecutando, por ejemplo, primero ```vagrant up main``` y
luego ```vagrant up worker```), pues los scripts elegirían contraseñas
de acceso a la BBDD distintas para uno y para otro y solo el del ```main```
(que tiene la BBDD) funcionaría.

Volviendo al fichero de configuración en ```/usr/local```, en la práctica
**no se debe tocar ese fichero**. En lugar de eso se debe modificar una copia
del fichero que está en el *home*
del usuario, en concreto en ```/home/cms/cmsCode/config/cms.conf```.
Una vez modificado, se puede utilizar el script ```installLocalConfigFile.sh```
que, antes de copiar el fichero a su localización definitiva, comprueba
que tiene una sintáxis JSON válida.

```bash
cms@cms-OIE:~$ nano /home/cms/cmsCode/config/cms.conf
[...]
cms@cms-OIE:~$ installLocalConfigFile.sh 
cms@cms-OIE:~$ 
```

Es importante hacerlo de esta forma pues también los *scripts* de utilidad
disponibles en las máquinas lo hacen así, de esta forma asumen que ambos ficheros
*son iguales*. Si el usuario modifica el de ```/usr/local/etc```, los cambios
serán sobreescritos la próxima vez que se utilice alguno de esos scripts.

Obviamente, después de la actualización del fichero de configuración seguramente
necesites relanzar el servicio de CMS afectado. Para eso se puede utilizar
el script ```restartCMSService.sh``` o simplemente ```system restart <servicio>```.

## nginx

Las diferentes páginas web son responsabilidad de los servicios correspondientes
que escuchan en puertos concretos (por ejemplo el 8888 en el caso de la
web de participantes).

Será raro que se necesite cambiar algo de su configuración (a excepción
de ajustes particulares en los rankings, tal y como se cuenta [aquí](Rankings.md)).

No obstante, por si acaso es necesario, se debe tener en cuenta que
en el directorio ```/etc/nginx/conf.d``` se encuentran, en ficheros
independientes, cada uno de los *upstream* apuntando al puerto del servicio
correspondiente. Por ejemplo, en la máquina con el rol ```contestfrontend```
existe el fichero ```/etc/nginx/conf/cws.conf``` que tiene la definición
del *upstream* ```cws``` apuntando al puerto local 8888. Además hay un upstream
por cada uno de los rankings, llamados rwsXX (XX = id del ranking).

Por otro lado el directorio ```/etc/nginx/sites-available/cms-endpoints```
tiene los ficheros en los que se enlaza una URL concreta con el *upstream*
respectivo. Por ejemplo, el fichero ```/etc/nginx/sites-available/cms-endpoints/contestfrontend.conf```
enlaza la ruta ```/participante``` con el ```cws``` anterior.

En ese mismo directorio hay un fichero ```root.conf``` que redirige el
tráfico que llega a la ruta raíz de la máquina al *upstream* deseado.
La instalación de CMS-OIE determina cuál es el *upstream* más conveniente
para la máquina en cuestión. Si se desea cambiar, es aquí donde debe
hacerse.

Tras cambiar los ficheros de configuración, no se debe olvidar relanzar nginx:

```bash
cms@cms-OIE:~$ sudo service nginx restart
[sudo] password for cms: 
cms@cms-OIE:~$ 
```

## scripts disponibles

Aquí aparece la lista de scripts disponibles en CMS-OIE (algunos de ellos
están únicamente disponibles si la máquina juega un rol específico):

   - ```restarCMSService.sh```: relanza un servicio de CMS dado como parámetro 
   (requiere ser root). En realidad es equivalente a hacer un
   ```system restart <servicio>```.
   - ```enableCMSService.sh```/```disableCMSService.sh```: parecidos
   al anterior pero para lanzar servicios que aún no están lanzados,
   o parar servicios que sí lo están. El script no solo lanza/para el
   servicio correspondiente sino que configura el sistema para que éste
   *se lance también al arrancar la máquina* (o deje de lanzarse en
   el caso de ```disableCMSService.sh```).
   - ```getActivateContest.sh```: mirando los servicios que hay lanzados
   en el sistema, intenta determinar qué concurso es el que está habilitado
   en CMS (es decir, qué concurso se está utilizando para actualizar rankings,
   qué concurso aparece en la lista de concursos en la página inicial
   de los participantes, etc.).
   - ```activateContest.sh```: activa el concurso cuyo ID se pasa como
   parámetro. Si ese concurso es el que estaba activado, el script no
   hace nada. Si había otro concurso activado, se desactivará, pues únicamente
   puede haber un concurso activo a la vez.
   - ```installLocalConfigFile.sh```: tras comprobar que el fichero
   ```/home/cms/cmsCode/config/cms.conf``` es un JSON válido, lo copia a la
   localización de la que leen los servicios de CMS para que pase a ser
   el nuevo fichero de configuración de CMS.
   - ```enableRankingUpdates.sh```: habilita la actualización del ranking
   cuyo id se indica como parámetro. Más detalles [aquí](Rankings.md).
   - ```disableRankingUpdates.sh``: igual que el anterior, pero para
   deshabilitar la actualización.
   - ```disableAllRankingUpdates.sh```: deshabilita la actualización
   de *todos* los rankings.

Para que el listado sea completo, aparecen aquí otros scripts también
instalados pero que, o bien se utilizan como soporte de los scripts anteriores
o bien son utilizados de forma puntual y no es normal necesitarlos en el
"día a día":

   - ```patchLocalConfigFile.sh```: sirve para "parchear" el fichero
   de configuración añadiendo/eliminando partes del JSON. Utiliza
   sintaxis de ```jq```.
   - ```initRanking.sh```, ```publishRankingWeb.sh``` y ```unpublishRankingWeb.sh```
   sirven para gestionar los rankings. Están explicados en el
   [documento específico sobre gestión de rankings](Rankings.md).
   - ```registerTestContest.sh``` y ```simulateSubmissions.sh``` se utilizan
   para hacer una primera prueba de funcionamiento de CMS y carga del
   sistema. Están descritos [aquí](PrimerosPasos.md). No están en el path,
   sino que se instalan (si se configuró concurso de prueba) en
   ```/home/cms/concurso-prueba```.
