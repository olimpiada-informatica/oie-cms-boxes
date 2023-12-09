# TestBox: desplegado de CMS básico

Una única máquina virtual pensada principalmente para familiarizarse
con CMS y no tanto para desplegarse en un servidor y ser utilizada durante
un concurso.

## Modo de uso TL;DR

Basta con crear la máquina virtual y lanzarla desde una consola con:

```shell
cp .env.template .env
vagrant up
```

a continuación se puede dirigir un navegador a:

- Interfaz de administración : http://192.168.10.11/admin (credenciales: `admin`/`adminCMS`)
- Interfaz de participante: http://192.168.10.11/participante (si se indicó `CONCURSO_PRUEBA` en `.env`, credenciales: `harry`/`potter`).
- Clasificación del concurso: http://192.168.10.11/clasif Si no se indicó
`CONCURSO_PRUEBA` en `.env`, aparecerá vacío.

Si las páginas anteriores no responden es posible que se trate de un
problema de la configuración de red del sistema de virtualización. 
VirtualBox se crea una red nueva en el sistema (normalmente de
nombre `vboxnet0`) y podría ser que el interfaz de red (virtual) para
acceder a ella no esté lanzado. Si es así se puede lanzar con:

```shell
sudo ifconfig vboxnet0 192.168.10.1/24
```

## Modo de uso detallado

Las distintas (pocas) propiedades configurables de la máquina se establecen
en el fichero `.env`; se puede utilizar como inspiración el contenido de
[`.env.template`](.env.template).

Si la máquina se va a utilizar únicamente para pruebas locales, con la
configuración por defecto valdrá. Si se va a utilizar para algo más,
**no olvidar cambiar la contraseña del administrador**.

La máquina lanza CMS y el resto de procesos satélites. Todos ellos son accesibles a través de `http` en distintas rutas (`admin`, `clasif` y `participante`). A esas
rutas se llega gracias a un `nginx` que hace de proxy a cada uno de
los servicios. La máquina, además, tiene disponibles en el PATH los comandos de
[cms-utils](https://github.com/olimpiada-informatica/cms-utils).

Si se indica `CONCURSO_PRUEBA=1` se añadirá a la instancia del CMS
[este concurso de prueba](https://github.com/olimpiada-informatica/cms-ejemplo-concurso)
y se poblará con equipos y participantes (los usuarios y contraseñas
pueden verse [aquí](https://docs.google.com/spreadsheets/d/1DNZ4kaNdbEPauDCkgZ28x01FDKPuLsbMpns1tRb0k-o/)).
Además, se simularán envíos de esos participantes de forma que inmediatamente
tras el lanzamiento de CMS comenzará su evaluación.

Si no se desea un concurso de prueba (comentando la línea `CONCURSO_PRUEBA=1`),
se tendrá una instalación limpia de CMS con
un único usuario administrador cuyas credenciales se cogen del `.env`. En ese caso
se podrán utilizar los scripts de cms-utils para añadir usuarios, tareas, etc.

Eso sí, es importante hacer notar que si el concurso se crea después del lanzamiento
de la máquina el ranking *no* funcionará automáticamente, por el modo de funcionamiento
de CMS. En concreto, el responsable del fallo es el `cmsProxyServer` (servidor que comunica
CMS con el servidor del ranking) pues si se lanza sin concurso activo (cosa
que ocurre si no se define `CONCURSO_PRUEBA=1`) termina inmediatamente.

La solución es o bien rearrancar la máquina, para que vuelva a relanzar el servicio o bien
lanzarlo manualmente con

```bash
$ sudo systemctl start cmsProxyService@1.service
```
