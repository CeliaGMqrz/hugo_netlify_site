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
auto eth0
iface eth0 inet dhcp
#       post-up ip route del default dev $IFACE || true

# Reglas de iptable
up iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
down iptables -t nat -D POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE

# Additional interfaces, just in case we're using
# multiple networks

#Red interna
auto eth1
iface eth1 inet static
        address 10.0.1.6
        netmask 255.255.255.0

# Set this one last, so that cloud-init or user can
# override defaults.
source /etc/network/interfaces.d/*


```

Comprobamos que las reglas de iptable estan funcionando

```powershell
sudo iptables -t nat -L -nv
```

```powershell
debian@dulcinea:~$ sudo iptables -t nat -L -nv
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    7   588 MASQUERADE  all  --  *      eth0    10.0.1.0/24          0.0.0.0/0           

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination    
```

## 4. Definición de contraseña en todas las instancias

* Accedemos a Sancho y a Quijote por ssh desde Ducinea.
* Le cambiamos la contraseña a todas las instancias.

```powershell
passwd root
passwd nombre_de_usuario ({debian},{ubuntu},{sancho})
``` 

## 5. Modificación de las instancias sancho y quijote para que usen direccionamiento estático y dulcinea como puerta de enlace

### Configuración Sancho (Ubuntu)

Editamos el fichero de configuración de interfaces

```powershell
nano -c /etc/netplan/50-cloud-init.yaml
```

```powershell
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        ens3:
             addresses: [10.0.1.11/24]
             gateway4: 10.0.1.6
             dhcp4: false
             match:
                macaddress: fa:16:3e:cd:4d:70
             mtu: 8950
             set-name: ens3

```

Aplicamos los cambios

```powershell
netplan apply
```

Comprobamos que la* puerta de enlace* apunte a Dulcinea

```powershell
root@sancho:/home/ubuntu# ip r
default via 10.0.1.6 dev ens3 
10.0.1.0/24 dev ens3 proto kernel scope link src 10.0.1.11 
169.254.169.254 via 10.0.1.2 dev ens3 
```

Comprobamos que tenemos *acceso al exterior*

```powershell
root@sancho:/home/ubuntu# ping 172.22.0.1
PING 172.22.0.1 (172.22.0.1) 56(84) bytes of data.
64 bytes from 172.22.0.1: icmp_seq=1 ttl=62 time=1.47 ms
64 bytes from 172.22.0.1: icmp_seq=2 ttl=62 time=1.87 ms
^C
--- 172.22.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 1.467/1.670/1.874/0.203 ms

```

### Configuración Quijote (CentOS)

Buscamos el fichero de configuración de interfaces

```powershell
[centos@quijote ~]$ ls -l /etc/sysconfig/network-scripts/ifcfg-*
-rw-r--r--. 1 root root 168 Nov 18 16:58 /etc/sysconfig/network-scripts/ifcfg-eth0
-rw-r--r--. 1 root root 254 Aug 19  2019 /etc/sysconfig/network-scripts/ifcfg-lo

```
Editamos el fichero:

```powershell
vi /etc/sysconfig/network-scripts/ifcfg-eth0 
```
```powershell
# Created by cloud-init on instance boot automatically, do not edit.
#
BOOTPROTO="static"
IPADDR="10.0.1.13"
GATEWAY="10.0.1.6"
DEVICE=eth0
HWADDR=fa:16:3e:f7:be:35
MTU=8950
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
~                                                                                                        
~                                                                                                        
~                                                                                                        
~                                                                                                        
~                                                                                                        
~                                                                                                        
"/etc/sysconfig/network-scripts/ifcfg-eth0" 11L, 210C

```

Reiniamos el servicio

```powershell
systemctl restart network.service
```

Comprobamos la **puerta de enlace**:

```powershell
[root@quijote centos]# ip r
default via 10.0.1.6 dev eth0 
10.0.0.0/8 dev eth0 proto kernel scope link src 10.0.1.13 

```

Comprobamos el **acceso al exterior**:

```powershell
[root@quijote centos]# ping 172.22.0.1
PING 172.22.0.1 (172.22.0.1) 56(84) bytes of data.
64 bytes from 172.22.0.1: icmp_seq=1 ttl=62 time=1.36 ms
64 bytes from 172.22.0.1: icmp_seq=2 ttl=62 time=1.50 ms
^C
--- 172.22.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 1.364/1.432/1.500/0.068 ms

```

