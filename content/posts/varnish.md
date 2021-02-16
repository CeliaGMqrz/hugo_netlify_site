---
title: "Aumento del rendimiento de Nginx con Varnish"
date: 2021-02-16T17:15:21+01:00
draft: false
toc: false
images:
tags: ['varnish','rendimiento', 'apache', 'nginx']
---

> Para ver la introducción a este tema puedes entrar en este post:

[Gestión de peticiones y rendimiento de servidores Web]()

## 1. Concepto: Varnish

Varnish es un acelerador de HTTP que funciona como **proxy inverso**. Se sitúa delante del servidor web, cacheando la respuesta del servidor web en memoria. De forma que cuando un cliente demanda la url por segunda vez, Varnish le da la respuesta ahorrando recursos en el backend y permitiendo más conexiones simultáneas. También se puede usar como **balanceador de carga**.

Características:

* Es estable y muy rápido
* Dispone de un lenguaje propio de configuración llamado VCL
* Escrito en C
* Ofrece soporte para GZIP y ESI


## 2. Aumento de rendimiento en la ejecución de scrips PHP

### 2.1. Configurar una máquina con Nginx + fpm_php. Ansible.

Vamos a configurar una máquina con Nginx y el módulo de fpm_php. Para que sea más rápido vamos a usar un repositorio preparado con una receta para Ansible. 

Previamente tenemos que haber configurado el [entorno virtual para Ansible]().

* Desde el entorno virtual vamos a clonar el siguiente [repositorio](https://github.com/josedom24/ansible_nginx_fpm_php)


