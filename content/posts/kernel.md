---
title: "Compilación de un kernel linux a medida"
date: 2020-11-15T20:07:29+01:00
draft: false
toc: false
images:
tags: ['kernel linux']
---


Ejercicio planteado:

Al ser linux un kérnel libre, es posible descargar el código fuente, configurarlo y comprimirlo. Además, esta tarea a priori compleja, es más sencilla de lo que parece gracias a las herramientas disponibles.

En esta tarea debes tratar de compilar un kérnel completamente funcional que reconozca todo el hardware básico de tu equipo y que sea a la vez lo más pequeño posible, es decir que incluya un vmlinuz lo más pequeño posible y que incorpore sólo los módulos imprescindibles. Para ello utiliza el método explicado en clase y entrega finalmente el fichero deb con el kérnel compilado por ti.

El hardware básico incluye como mínimo el teclado, la interfaz de red y la consola gráfica (texto).

______________________________________________________________________________________

1. Obtener el código fuente del kernel

Buscamos las fuentes en la paqueteria de Debian

```sh
apt search linux-source
```

Salida:

```sh
linux-source/stable 4.19+105+deb10u7 all
  Linux kernel source (meta-package)

linux-source-4.19/stable 4.19.152-1 all
  Linux kernel source for version 4.19 with Debian patches

```
Segun la versión de kernel que tenemos instalado:

```sh
apt policy linux-source
```
```sh
linux-source:
  Instalados: (ninguno)
  Candidato:  4.19+105+deb10u7
  Tabla de versión:
     4.19+105+deb10u7 500
        500 http://security.debian.org/debian-security buster/updates/main amd64 Packages
     4.19+105+deb10u6 500
        500 http://deb.debian.org/debian buster/main amd64 Packages
```

Entonces descargamos la versión del kernel que nos pertenece. Además del paquete build-essential y qtbase5-dev, que son esenciales para su compilación.

```sh
apt install linux-source=4.19+105+deb10u7 build-essential qtbase5-dev
```

2. Descomprimir las fuentes en un directorio 'seguro' como usuario.

```sh
mkdir /home/celiagm/compilar_kernel
sudo mv linux-source-4.19.tar.xz /home/celiagm/compilar_kernel/
cd /home/celiagm/compilar_kernel/
tar -xf linux-source-4.19.tar.xz 
```

Vemos el tamaño

```sh
celiagm@debian:~/compilar_kernel$ du -hs linux-source-4.19
910M	linux-source-4.19

```
Vemos el contenido de nuestras fuentes

```sh
celiagm@debian:~/compilar_kernel$ cd linux-source-4.19/
celiagm@debian:~/compilar_kernel/linux-source-4.19$ ls
arch   COPYING  Documentation  fs       ipc      kernel    MAINTAINERS  net      scripts   tools
block  CREDITS  drivers        include  Kbuild   lib       Makefile     README   security  usr
certs  crypto   firmware       init     Kconfig  LICENSES  mm           samples  sound     virt
```

Para ver la ayuda de make

```sh
make help
```


3. Copiar la configuración del kernel que tenemos actualmente en nuestro sistema para que 'make oldconfig' le indique esa configuración a nuestro kernel nuevo.

Esta es la opción que nos muestra la ayuda
```sh
 oldconfig	  - Update current config utilising a provided .config as base
```

Ahora copiamos el fichero 'config' a nuestro directorio

```sh 
cp /boot/config-4.19.0-12-amd64 .config
```

Ejecutamos **make oldconfig**

```sh
make oldconfig
```

Miramos el número de elementos que se van a compilar como modulos y estaticamente.

Modulos:

```sh
grep "=m" .config|wc -l
```

Estatica:

```sh
grep "=y" .config|wc -l
```

```sh
celiagm@debian:~/compilar_kernel/linux-source-4.19$ grep "=m" .config|wc -l
3381
celiagm@debian:~/compilar_kernel/linux-source-4.19$ grep "=y" .config|wc -l
2013
```

4. Selección y reducción de elementos de parte de **localmodconfig** que modifica el fichero .config

```sh
make localmodconfig
```
Vemos que se ha reducido sifgnificativamente.

```sh
celiagm@debian:~/compilar_kernel/linux-source-4.19$ grep "=m" .config|wc -l
182
celiagm@debian:~/compilar_kernel/linux-source-4.19$ grep "=y" .config|wc -l
1449
```

5. Realizamos la primera compilación (indicandole el numero de nucleos que vayamos a utilizar para agilizar el proceso)

Nos aseguramos que tenemos estos paquetes instalados:

```sh
libelf-devel
libssl-dev
pkg-config
```
Procedemos a la compilación

```sh
make -j 4 bindeb-pkg
```

6. Comprobar el peso del fichero deb, en el directorio padre que es donde se han generado los ficheros deb

```sh
celiagm@debian:~/compilar_kernel$ du -hs linux-image-4.19.152_4.19.152-1_amd64.deb 
11M	linux-image-4.19.152_4.19.152-1_amd64.deb

```

7. Instalarlo y comprobar funcionamiento

Ver los kernels instalados

```sh
dpkg -l | grep linux-image
```

Desinstalar el kernel que **no funciona** cuando sea necesario:

```sh
apt-get remove --purge linux-image-X.X.X-X
```

```sh
sudo dpkg -i linux-image-4.19.152_4.19.152-1_amd64.deb 
```
Vemos que funciona correctamente.

```sh
celiagm@debian:~$ uname -r
4.19.152

```

8. Reducir elementos. Con el siguiente comando se nos abre una ventana y podemos elegir los módulos o elementos que queremos quitar.


```sh
make xconfig
```

1º REDUCCIÓN

```sh
RF switch subsystem support (RFKILL): soporte para interruptor de tarjetas wifi y bluetooh
Bluetooth subsystem support (BT): Bluetooth
QoS and/or fair queueing (NET_SCHED): elegir paquetes retraso primero o en cola
Network packet filtering framework (Netfilter) (NETFILTER): filtrado de paquetes, cortafuegos
Multimedia support (MEDIA_SUPPORT): Soporte para multimedia
Sound card support (SOUND): Soporte para el sonido
Linux guest support (HYPERVISOR_GUEST): Soporte para maquinas virtuales
Macintosh device drivers (MACINTOSH_DRIVERS)
Macintosh device drivers (MACINTOSH_DRIVERS)
Hardware Monitoring support (HWMON): Monitoreo de hardware
Hardware crypto devices (CRYPTO_HW): Encriptación de hardware
Virtualization (VIRTUALIZATION)

```
Numero de elementos:
```sh
```

Tamaño conseguido:
```sh
celiagm@debian:~/compilar_kernel$ du -hs linux-image-4.19.152_4.19.152-1_amd64.deb 
9,1M	linux-image-4.19.152_4.19.152-1_amd64.deb

```

