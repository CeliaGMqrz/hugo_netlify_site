---
title: "VPN con OpenVPN y certificados x509 (II)"
date: 2021-02-24T08:27:54+01:00
draft: false
toc: false
images:
tags: ['vpn']
---

Escenario:

Tenemos dos servidores y dos clientes. Los servidores están conectados a dos redes la exterior en común y una interna compartida con su respectivo cliente de forma que tenemos el siguiente direccionamiento:


* Servidor 1: vpn_server
  * Red 10.0.0.15
  * Red1 192.168.100.2
* Cliente 1: lan
  * Red1 192.168.100.10

* Servidor 2: vpn_server2
  * Red 10.0.0.13
  * Red2 192.168.200.7
* Cliente 2: lan2
  * Red2 192.168.200.4


Objetivo:

Tras el establecimiento de la VPN, una máquina de cada red detrás de cada servidor VPN debe ser capaz de acceder a una máquina del otro extremo. En otras palabras el cliente 1 debe de tener comunicacion al cliente 2 por un tunel, ya que se encuentran en redes diferentes.

Cabe decir que tenemos instalado en las 4 máquinas el paquete openvpn.

Configuración

Servidor 1

`sudo nano /etc/openvpn/servidor.conf `

```sh
# Use a dynamic TUN device
dev tun

# Connect to server
remote 10.0.0.15

# Set virtual point-to-point IP addresses
ifconfig 10.99.99.0 255.255.255.0
pull

# Use TCP for communicating with server
proto tcp-client

# Enable TLS and assume client role during TLS handshake
tls-client

# Certificado de la CA
ca /etc/openvpn/keys/ca.crt

# Certificado del cliente
cert /etc/openvpn/keys/cliente.crt

# Clave privada del cliente
key /etc/openvpn/keys/cliente.key

# Use fast LZO compression
comp-lzo

# Ping remote every 10sg and restart after 60sg passed without sign of life from remote
keepalive 10 60

# Set output verbosity to normal usage range 
verb 3

# Output logging messages to openvpn.log file
log /var/log/openvpn.log
```