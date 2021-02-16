---
title: "Cortafuegos perimetral. Iptables"
date: 2021-01-25T17:15:21+01:00
draft: false
toc: false
images:
tags: ['cortafuegos','iptables']
---

## Introducción

Vamos a construir un **cortafuegos** en dulcinea que nos permita controlar el tráfico de nuestra red. El cortafuegos que vamos a construir debe funcionar tras un reinicio.

La política por defecto que vamos a configurar en nuestro cortafuegos será de tipo **DROP**.

## NAT

* Las máquinas de nuestra red tienen que tener acceso al exterior

Estas reglas de iptables ya estaban configuradas en ejercicios anteriores, son las siguientes:

```sh
up iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
up iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eth0 -j MASQUERADE
```

Si miramos las reglas aplicadas comprobamos que están en funcionamiento

```sh

```