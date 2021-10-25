# Máquinas virtuales para ejecutar CMS para concursos asociados a la OIE

La OIE aconseja el uso de [CMS](https://github.com/cms-dev/cms) (Contest 
Management System) como software para la gestión de los concursos regionales
y nacional, pues es el software utilizado por la
[Olimpiada Informática Internacional](https://ioinformatics.org/).

El objetivo de este repositorio es facilitar a los organizadores de los
concursos tener una instancia de CMS funcionando, ya sea para utilizarla
localmente para una primera aproximación a CMS, para que el equipo
de elaboración de problemas pueda hacer pruebas locales durante 
la creación del juego de tareas o para desplegarlo en un servidor
que sea utilizado durante el concurso. Más abajo se detallan las
distintas alternativas de desplegado proporcionadas.

Nótese, no obstante, que las distintas opciones dadas **no** son
las únicas posibles. Dependiendo de la infraestructura de red que tenga el centro
organizador y de la tolerancia ante fallos que se quiera conseguir se podría
necesitar una configuración distinta. En ese caso, este repositorio puede servir,
no obstante, como ejemplo de cómo lanzar CMS para después adaptarlo a la situación
concreta.

El repositorio tiene ramas distintas para cada una de las ediciones
de la OIE en las que se ha utilizado CMS. La organización de la OIE intentará
publicar con cierta antelación las máquinas virtuales aconsejadas para
la edición correspondiente.

Por ejemplo, para la edición de 2022 de la OIE puedes descargarte el repositorio
con:

```bash
$ git clone https://github.com/olimpiada-informatica/oie-cms-boxes --branch oie-2022
```

Todas las opciones de desplegado hacen uso de una *versión adaptada* de CMS
para su uso en la OIE que está disponible en
[este repositorio específico](https://github.com/olimpiada-informatica/cms). Las
adaptaciones son mínimas y pueden verse en su histórico de commits.

Todas las opciones de desplegado hacen uso de la **versión 1.4** modificada de CMS usando
Ubuntu~18.04 que es la versión de Linux probada por los propios desarrolladores de
CMS. Además, cuando el entorno de virtualización utilizado es VirtualBox,
los scripts ajustan algunas opciones de las máquinas virtuales (memoria y CPUs virtuales).
Si utilizas un sistema distinto, es posible que quieras ajustar esa configuración
en los `Vagrantfiles`.

El desplegado incorpora todo lo necesario para que los concursos puedan admitir
como lenguajes C, C++, Java y Python.

**ADVERTENCIA** Dado que los scripts construyen una (o varias) máquinas virtuales,
su ejecución requiere un espacio considerable en disco (varios gigas) y una
buena conexión a internet para descargar todos los recursos.

## Uso

Las distintas formas aquí presentadas para lanzar CMS se basan en el uso de
máquinas virtuales. El repositorio hace uso de
[Vagrant](https://es.wikipedia.org/wiki/Vagrant_(software)) para crear esas
máquinas virtuales en el sistema de virtualización que se desee (típicamente
VirtualBox).

Para aquellos que no conozcan Vagrant, vaya aquí una rápida introducción y
por qué encaja perfectamente para nuestro cometido.

Vagrant es una herramienta que sirve para *crear máquinas virtuales* que después
serán ejecutadas por VirtualBox o cualquier otro sistema de virtualización
soportado por ésta. La creación se hace en base a unos *scripts* de texto que
son los que aparecen en este repositorio. El resultado de la ejecución de esos
scripts es una o más máquinas virtuales ejecutables en el sistema de
virtualización. Para aquellos que no conozcan previamente Vagrant pero sí el
concepto de contenedor, decir que ambos son similares. La diferencia fundamental
es que el resultado final de Vagrant son máquinas virtuales completas (con un
sistema operativo concreto, por ejemplo) mientras que los contenedores utilizan
el sistema operativo del *host* que lo ejecuta.

El uso de Vagrant encaja en nuestro propósito porque nos permite proporcionar
los scripts que montan las máquinas virtuales en lugar de compartir ficheros
de gran tamaño con las máquinas virtuales ya configuradas. La existencia de
esos scripts de creación permite a los organizadores, además, ajustar su
funcionamiento a las características concretas de su instalación de red.
Esta personalización de las máquinas puede hacerse, obviamente, bien en
los propios scripts antes de la creación de las máquinas virtuales o bien
después conectándose por SSH a ellas.

Dependiendo del tipo de acceso que los organizadores del concurso tengan al
servidor (o servidores) que ejecutarán CMS durante el concurso, el uso de
este repositorio será ligeramente distinto.

Si los organizadores tienen acceso directo a los servidores vía SSH y no
tienen restricciones de uso (típicamente, tienen acceso de administrador),
entonces pueden "montar" las máquinas virtuales directamente en el servidor
haciendo uso de los scripts de este repositorio y personalizarlas.

Si no se tiene acceso directo, entonces se pueden montar las máquinas virtuales
en una máquina local y proporcionar a los responsables TIC del centro los
ficheros de las máquinas virtuales (de VirtualBox, etc.) completamente configuradas
para su lanzamiento. Eso sí, es importante saber que la administración de CMS
requiere acceso por SSH a la máquina en la que está instalado (para ejecutar
comandos por consola), por lo que es indispensable que los responsables TIC
den acceso a ella de alguna forma.

### Ciclo de vida de las máquinas virtuales

En general, la creación de una máquina virtual con Vagrant se hace desde la
línea de órdenes con `vagrant up`, por ejemplo:

```bash
# Lanzamos la máquina virtual de TestBox
$ cd TestBox
$ cp .env.template .env
$ emacs .env
# ... configurar las propiedades ...
$ vagrant up
```

La primera vez que se lanza, `Vagrant` configurará la máquina virtual,
instalando los paquetes necesarios, etc. En la consola se podrá ver el proceso.
El resultado es una máquina virtual completamente funcional y que se lanzará
utilizando el sistema de virtualización configurado (típicamente
VirtualBox). De hecho, si se abre VirtualBox se verá toda la información
de la máquina virtual. Tras su apagado, se puede incluso coger el fichero
y llevarla a otro servidor (los ficheros en Linux con Virtual Box
suelen encontrarse en `~/VirtualBox VMs`).

Una vez creada la máquina, desde el mismo directorio nos podemos
conectar por SSH a ella con el usuario que `Vagrant` crea por defecto
(`vagrant`):

```bash
$ vagrant ssh
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-156-generic x86_64)

[...]

vagrant@cms-OIE:~$ 
```

Esa consola nos permite ver la instalación y ajustarla a nuestras necesidades.

Para parar la máquina podemos confiar en la consola de VirtualBox (o el sistema
de virtualización correspondiente) o utilizar el propio `Vagrant`:

```bash
# Apagamos la máquina (desde una consola en el host situada
# en el directorio TestBox)
$ vagrant halt
```

Para volver a lanzarla/encenderla, bastará ejecutar de nuevo `vagrant up`. Al
estar la máquina ya creada y configurada, no se volverá a pasar por el
proceso de instalación de CMS.

Por último, tras terminar las pruebas podemos eliminar por completo la máquina
virtual, bien desde VirtualBox bien desde la consola con `Vagrant`:

```bash
# Destruimos la máquina (desde una consola en el host situada
# en el directorio TestBox)
$ vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
```

## Prerequisitos

Como se ha dicho, los scripts hacen uso de [Vagrant](https://es.wikipedia.org/wiki/Vagrant_(software)).
Dependiendo del sistema operativo utilizado su instalación será distinta,
y requerirá tener instalado también algún sistema de virtualización.
Como ejemplo, en sistemas tipo Debian/Ubuntu la instalación puede ser algo como:

```bash
# Sistema de virtualización usado: VirtualBox
$ sudo apt-get install virtualbox
# Vagrant
$ sudo apt-get install vagrant
```

Tras lo cual será necesario reiniciar (en otro caso, Vagrant no utilizará VirtualBox
como sistema de virtualización y la ejecución de los scripts dará error).

Además, los scripts hacen uso del *plug-in* de Vagrant ~vagrant-env~ que se instala con

```bash
$ vagrant plugin install vagrant-env
```

Por último, como ya se ha dicho antes, los scripts construyen una o varias máquinas
virtuales por lo que se requiere un considerable espacio en disco (varios gigas)
y es preferible tener una buena conexión a internet para descargar todos los
recursos.

## Opciones de desplegado

Se proporcionan distintas opciones de desplegado con más o menos máquinas virtuales y
más o menos características. Todas ellas pueden, tras la creación de la máquina
virtual, personalizarse dependiendo de las necesidades concretas. Esa personalización,
eso sí, requerirá conocimientos de instalación de CMS.

Cada una de las opciones está en un directorio independiente. Se utilice la
versión que se utilice, se debe tener descargado *el respositorio entero* pues
todas ellas hacen uso de algunos directorios que hay en el raíz.

### TestBox

La versión más simple con una única máquina virtual con todos los servicios lanzados.
En el momento de la creación, se puede indicar que se quiere añadir un concurso
de prueba con equipos, usuarios y algunos problemas. Durante la instalación
se simulará el concurso haciendo envíos a él para poder ver el funcionamiento del
ranking.

Esta máquina es útil como primera aproximación a CMS, para que el equipo de
elaboración de problemas pueda probar en sus máquinas las distintas tareas, etc.

## Autores

Comité técnico de la [Olimpiada Informática Española](https://olimpiada-informatica.org):

- Marco Antonio Gómez Martín (Facultad de Informática - Universidad Complutense de Madrid)

## Créditos

- [CMS](https://github.com/cms-dev/cms) de [CMS-dev community](https://github.com/cms-dev/cms/blob/master/AUTHORS.txt)
- [CMS manual](http://cms.readthedocs.io/en/latest/index.html) de [CMS-dev community](https://github.com/cms-dev/cms/blob/master/AUTHORS.txt)
- [CMS-boxes](https://github.com/cms-orbits/cms-boxes/) de [CMS-orbit](https://github.com/cms-orbits)
