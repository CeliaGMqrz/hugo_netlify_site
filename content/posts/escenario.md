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

(Es necesario deshabilitar la seguridad en todos los puertos de dulcinea) [[https://youtu.be/jqfILWzHrS0]]

[Instalar Openstackclient y deshabilitar la seguridad de puertos](https://unbitdeinformacioncadadia.netlify.app/posts/2020/11/instalar-openstackclient-y-deshabilitar-la-seguridad-de-puertos/)