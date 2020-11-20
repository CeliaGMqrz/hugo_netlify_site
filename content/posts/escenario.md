---
title: "Instalación y configuración inicial de los servidores"
date: 2020-11-18T18:22:12+01:00
draft: false
toc: false
images:
tags: ["servidores"]
---

En esta tarea se va a crear el escenario de trabajo que se va a usar durante todo el curso, que va a constar inicialmente de 3 instancias con nombres relacionados con el libro "Don Quijote de la Mancha".


Pasos a realizar:

## 1. Creación de la red interna:
    
* Nombre red interna de <nombre de usuario>
* 10.0.1.0/24

## 2. Creación de las instancias

* **Dulcinea**:

    * **Debian Buster** sobre volumen de 10GB con sabor m1.mini
    * Accesible directamente a través de la red externa y con una IP flotante
    * Conectada a la red interna, de la que será la puerta de enlace

* **Sancho**:

    * **Ubuntu 20.04** sobre volumen de 10GB con sabor m1.mini
    * Conectada a la red interna
    * Accesible indirectamente a través de dulcinea

* **Quijote**:

    * **CentOS 7** sobre volumen de 10GB con sabor m1.mini
    * Conectada a la red interna
    * Accesible indirectamente a través de dulcinea

Escenario gráfico:

![escenario.png](/images/escenario/escenario.png)

## 3. Configuración de NAT en Dulcinea 

### 3.0. Deshabilitar la seguidad de puertos

Guía para: [Instalar Openstackclient y deshabilitar la seguridad de puertos](https://unbitdeinformacioncadadia.netlify.app/posts/2020/11/instalar-openstackclient-y-deshabilitar-la-seguridad-de-puertos/)


### 3.1. Activar el bit de fordward

Para que nuestra máquina actúe como router tenemos que activar el **bit de fordward.** Podemos hacerlo temporal o permanente. En este caso lo haremos permanente. Para ello editamos el fichero */etc/sysctl.conf* , buscamos la línea ‘**net.ipv4.ip_fordward=1**' y la descomentamos.

```powershell
nano /etc/sysctl.conf 
```

```powershell
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
```

### 3.2. Configurar las interfaces de red

En segundo lugar vamos a configurar el fichero */etc/network/interfaces* agregando dos reglas de **‘iptable’** para que nuestros clientes puedan acceder desde una interfaz a otra obteniendo acceso a internet. Añadiremos las siguientes líneas:

```powershell
nano /etc/network/interfaces
```

#### Reglas de iptable

Las añadimos de forma permanente en el fichero interfaces, de forma que:

* -A POSTROUTING (Añade una regla a la cadena POSTROUTING)

* -s ‘dirección’ : Se aplica a los paquetes que vengan de origen de la dirección especificada. En nuestro caso hemos añadido las direccion ip de nuestro cliente

* -o eth0: Se aplica a los paquetes que salgan por eth0 (la que sale al exterior)

* -j MASQUERADE: Cambia la dirección de origen (eth1) por la dirección de salida (eth0)

```powershell
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The normal eth0 (red externa)
allow-hotplug eth0
iface eth0 inet dhcp
        post-up ip route del default dev $IFACE || true

# Reglas de iptable
up iptables -t nat -A POSTROUTING -o eth0 -s 10.0.1.0/24 -j MASQUERADE
down iptables -t nat -D POSTROUTING -o eth0 -s 10.0.1.0/24 -j MASQUERADE

# Additional interfaces, just in case we're using
# multiple networks

#Red interna 
allow-hotplug eth1
iface eth1 inet dhcp

# Set this one last, so that cloud-init or user can
# override defaults.
source /etc/network/interfaces.d/*

```

Comprobamos que las reglas de iptable estan funcionando

```powershell
root@dulcinea:/home/debian#  iptables -t nat -L -nv
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
   49  4396 MASQUERADE  all  --  *      eth1    10.0.1.0/24          0.0.0.0/0           
    1   356 MASQUERADE  all  --  *      eth0    10.0.1.0/24          0.0.0.0/0           

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination    
```

