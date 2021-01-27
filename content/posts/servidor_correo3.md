---
title: "Servidor de Correos. Postfix (III)."
date: 2021-01-25T17:15:21+01:00
draft: false
toc: false
images:
tags: ['servidor de correos','DKIM']
---

## Gestión de correos desde un cliente

Tarea 8: Configura el buzón de los usuarios de tipo Maildir. Envía un correo a tu usuario y comprueba que el correo se ha guardado en el buzón Maildir del usuario del sistema correspondiente. Recuerda que ese tipo de buzón no se puede leer con la utilidad mail.

**Tarea 9**: Instala configura dovecot para ofrecer el protocolo IMAP. Configura dovecot de manera adecuada para ofrecer autentificación y cifrado

### 1. Conceptos:

* **Dovecot**: es un servidor de IMAP Y POP3 de código abierto para sistemas Linux. Puede trabajar con mbox y Maildir.
  
* **IMAP**: Es un protocolo de acceso a mensajes de Internet, que permite el acceso a mensajes almacenados en un servidor de internet. A través de IMAP se puede tener acceso al correo electrónico teniendo acceso a la red.
  
* **Pop**: Protocolo de oficina de correo. También es usado para la obtencion de mensajes de correo electrónico almacenados en un servidor remoto.

> **Diferencias entre IMAP y POP**: La diferencia principal entre estos dos protocolos es que IMAP almacena los mensajes en el servidor de correo mientras que POP3 los descarga y almacena de forma local.

**Tipos de buzones**

Hasta ahora hemos utilizado el buzon **mbox** a través del protocolo POP3, pero ahora vamos a utlizar el buzón **Maildir**, en el que los mensajes se guardan en un directorio llamado Maildir, imprescindible para el protocolo que vamos a usar **IMAP**.


### 2. Instalación de dovecot

* Instalamos los paquetes pertintentes que vamos a usar para dovecot

```sh
sudo apt install dovecot-imapd dovecot-pop3d dovecot-core
```

* Editamos el fichero de configuración de postfix de forma que lo modificamos asi

```sh
nano /etc
```
