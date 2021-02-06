---
title: "Servidor de Correos. Postfix (III)."
date: 2021-01-25T17:15:21+01:00
draft: false
toc: false
images:
tags: ['servidor de correos','dovecot', 'IMAP']
---

## Gestión de correos desde un cliente

### Tarea 8: Configurar postfix con Maildir

**Descripción:**

Configura el buzón de los usuarios de tipo Maildir. Envía un correo a tu usuario y comprueba que el correo se ha guardado en el buzón **Maildir** del usuario del sistema correspondiente. Recuerda que ese tipo de buzón no se puede leer con la utilidad mail.

**Configuración:**

* Para hacer esta tarea vamos a indicar a postfix en su configuración dónde se van a guardar los nuevos correos.

```sh
nano /etc/postfix/main.cf
``` 
* Añadimos la siguiente línea

```sh
home_mailbox = Maildir/
```

* Reiniciamos el servicio

```sh
sudo systemctl restart postfix
```

* Ahora vamos a probar si se ha configurado correctamente para ello vamos a instalar el siguiente paquete

```sh
sudo apt-get install mailutils
```

* Una vez instalado vamos a enviar un correo desde la cuenta de root, comprobaremos que utilizando mail ya no aparece si no que se almacena en el directorio Maildir 

```sh
# Entramos como root
debian@kiara:~$ sudo su

# Enviamos un correo desde root
root@kiara:/home/debian# echo "mail body"| mail -s "test mail" root

# Comprobamos que no tenemos ningun mail desde la utilidad mail
root@kiara:/home/debian# mailq
Mail queue is empty
root@kiara:/home/debian# mail
No mail for root

# Entramos desde el directorio indicado y lo visualizamos 
root@kiara:/home/debian# ls Maildir/
cur  new  tmp

root@kiara:/home/debian# ls Maildir/new/
1612612909.V801I61f17M307843.kiara

root@kiara:/home/debian# cat Maildir/new/1612612909.V801I61f17M307843.kiara 
Return-Path: <root@iesgn05.es>
X-Original-To: root
Delivered-To: root@iesgn05.es
Received: by kiara.iesgn05.es (Postfix, from userid 0)
	id 47E4661F15; Sat,  6 Feb 2021 12:01:49 +0000 (UTC)
To: root@iesgn05.es
Subject: test mail
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20210206120149.47E4661F15@kiara.iesgn05.es>
Date: Sat,  6 Feb 2021 12:01:49 +0000 (UTC)
From: root <root@iesgn05.es>

mail body
```

Esto mismo lo podemos hacer con el usuario debian y sería el mismo procedimiento.

### Tarea 9: Instalación de dovecot. Protocolo IMAP.

**Descripción:**
Instala configura dovecot para ofrecer el protocolo IMAP. Configura dovecot de manera adecuada para ofrecer autentificación y cifrado

#### 9.11. Conceptos:

* **Dovecot**: es un servidor de IMAP Y POP3 de código abierto para sistemas Linux. Puede trabajar con mbox y Maildir.
  
* **IMAP**: Es un protocolo de acceso a mensajes de Internet, que permite el acceso a mensajes almacenados en un servidor de internet. A través de IMAP se puede tener acceso al correo electrónico teniendo acceso a la red. Se ejecuta en los puertos 143 y 993 (SSL). 

Es importante saber que utiliza la **sincronización** para garantizar que se guarde una copia de los mensajes en los diferentes directorios inicados en el servidor y así quedarán ordenados los correos.
  
* **Pop**: Protocolo de oficina de correo. También es usado para la obtencion de mensajes de correo electrónico almacenados en un servidor remoto. Ya no se utliza normalmente.

> **Diferencias entre IMAP y POP**: La diferencia principal entre estos dos protocolos es que IMAP almacena los mensajes en el servidor de correo y sus copias en los directorios de forma ordenada mientras que POP3 los descarga y almacena de forma local sólo en la bandeja de entrada.

**Tipos de buzones**

Hasta ahora hemos utilizado el buzon **mbox** a través del protocolo POP3, pero ahora vamos a utlizar el buzón **Maildir**, en el que los mensajes se guardan en un directorio llamado Maildir, imprescindible para el protocolo que vamos a usar **IMAP**.

> La configuracion de **maildir** la hemos realizado en la tarea anterior.

#### 9.2. Instalación de dovecot

* Instalamos los paquetes pertintentes que vamos a usar para dovecot. 

> No es necesario descargar *dovecot-pop3d* porque en esta práctica solo vamos a usar IMAP, pero puede ser interesante descargarlo para probar su funcionamiento.

```sh
sudo apt install dovecot-imapd dovecot-pop3d dovecot-core
```

* Editamos el fichero de configuración de los permisos de acceso para postfix

```sh
nano /etc/dovecot/conf.d/10-auth.conf
```

**¡¡ATENCIÓN!!**

En la siguiente linea si la descomentamos e indicamos un 'no' , tenemos que ser conscientes de que la seguridad de nuestro servidor está en juego. Se recomienda dejarlo en 'yes' para que los usuarios se autentifiquen sólo a través de conexiones seguras con SSL/TLS. **Utilizar IMAP sin SSL/TLS se considera imprudente.**

* Cambiamos la configuracion del siguiente fichero de esta forma:

```sh
sudo nano /etc/dovecot/conf.d/10-mail.conf
```

```sh
disable_plaintext_auth = yes
```

* Estamos modificando la ruta de donde se guardan los correos al directorio personal en la raiz donde se encuentra Maildir.

```sh
mail_location = maildir:~/Maildir  
```

Tendremos que crear también un CNAME en la zona dns que apunte a imap, y asegurarnos que el puerto 143 y el 993 estén abiertos.


* Miramos si los puertos están abiertos

```sh
debian@kiara:~$ sudo netstat -putona | grep '143'
tcp        0      0 0.0.0.0:143             0.0.0.0:*               LISTEN      313/dovecot          off (0.00/0/0)
tcp6       0      0 :::143                  :::*                    LISTEN      313/dovecot          off (0.00/0/0)


debian@kiara:~$ sudo netstat -putona | grep '993'
tcp        0      0 0.0.0.0:993             0.0.0.0:*               LISTEN      1096/dovecot         off (0.00/0/0)
tcp6       0      0 :::993                  :::*                    LISTEN      1096/dovecot         off (0.00/0/0)

```

* Creamos el CNAME en la zona DNS

![imap.png](/images/ovh_correo/imap.png)


* Habilitamos la opción 'protocols' estableciendo como valor imap

```sh
# Editar el fichero
sudo nano /etc/dovecot/dovecot.conf
# Añadir la siguiente linea
protocols = imap
```

* Editamos el siguiente fichero

```sh
sudo nano /etc/dovecot/conf.d/10-mail.conf

# Dejamos la siguiente configuracion

mail_privileged_group = mail
mail_access_groups = mail
```

* Comprobamos que está habilitada la configuación para ssl

```sh
# SSL/TLS support: yes, no, required. <doc/wiki/SSL.txt>
ssl = yes

# PEM encoded X.509 SSL/TLS certificate and private key. They're opened before
# dropping root privileges, so keep the key file unreadable by anyone but
# root. Included doc/mkcert.sh can be used to easily generate self-signed
# certificate, just make sure to update the domains in dovecot-openssl.cnf
ssl_cert = </etc/dovecot/private/dovecot.pem
ssl_key = </etc/dovecot/private/dovecot.key
```

* Reiniciamos los servicios

```sh
sudo systemctl restart postfix
sudo systemctl restart dovecot
```

* Ahora vamos a ir a Evolution desde nuestra máquina anfitriona. Y seguiremos los siguientes pasosç

> Archivo > Nuevo > Cuenta de correo 

Indicamos el nombre del servidor de correos y nuestro nombre completo

![ev1.png](/images/ovh_correo/ev1.png)

Una vez verificada la direccion del servidor nos mostrará el protocolo que ofrece, en este caso solo estamos ofreciendo IMAP por lo que se nos pondrá por defecto.

Añadiremos el servidor donde ofrecemos imap, en este caso es **imap.iesgn05.es** que es el CNAME que agregamos previamente a nuestro DNS. Indicaremos el puerto 993 ya que, es el puerto seguro por donde va cifrada la conexión, con el método de cifrado TLS como habiamos configurado en los ficheros anteriormente.

La autentificación será por contraseña, en este caso es la contraseña de nuestro usuario debian.

![ev2.png](/images/ovh_correo/ev2.png)

Dejaremos por defecto las opciones de recepción

![ev3.png](/images/ovh_correo/ev3.png)

En este apartado veremos que seusará SMTP para la conexión al servidor. Indicaremos el nombre del servidor en este caso es **kiara.iesgn05.es y el puerto 465. 

![ev4.png](/images/ovh_correo/ev4.png)

Aquí nos mostrará un resumen de nuestra configuración

![ev5.png](/images/ovh_correo/ev5.png)

Le daremos a Siguiente y nos preguntará por el certificado que hemos proporcionado, como no esta firmado por una autoridad certificadora conocida nos preguntará si queremos aceptarla. En este caso como sabemos que es nuestra le damos a Aceptar permanentemente.

![confianza.png](/images/ovh_correo/confianza.png)

Ahora podemos ver que se nos ha agregado nuestra cuenta de correo del usuario debian sin problemas y vemos que tenemos el correo de prueba anteriormente enviado a root.


![correofinalizado.png](/images/ovh_correo/correofinalizado.png)


### Prueba de funcionamiento

Vamos a enviar un correo desde Gmail a debian@iesgn05.es y comprobamos que llega a la bandeja de entrada:


![prueba1.png](/images/ovh_correo/prueba1.png)


![prueba2.png](/images/ovh_correo/prueba2.png)


Podemos ver el log de la prueba que hemos realizado

```sh
Feb  6 14:35:34 kiara postfix/smtpd[2437]: connect from mail-wr1-f43.google.com[209.85.221.43]
Feb  6 14:35:34 kiara postfix/smtpd[2437]: 6FAD761EFC: client=mail-wr1-f43.google.com[209.85.221.43]
Feb  6 14:35:34 kiara postfix/cleanup[2443]: 6FAD761EFC: message-id=<9bc643a1862b8e4d59ba0148cbb0c92668fe4e2b.camel@gmail.com>
Feb  6 14:35:34 kiara postfix/qmgr[2359]: 6FAD761EFC: from=<cg.marquez95@gmail.com>, size=2662, nrcpt=1 (queue active)
Feb  6 14:35:34 kiara postfix/local[2444]: 6FAD761EFC: to=<debian@iesgn05.es>, relay=local, delay=0.02, delays=0.01/0.01/0/0, dsn=2.0.0, status=sent (delivered to maildir)
Feb  6 14:35:34 kiara postfix/qmgr[2359]: 6FAD761EFC: removed
Feb  6 14:35:34 kiara postfix/smtpd[2437]: disconnect from mail-wr1-f43.google.com[209.85.221.43] ehlo=2 starttls=1 mail=1 rcpt=1 bdat=1 quit=1 commands=7

```

Ahora vamos a intentar mandar un correo desde el servidor a gmail

![pruebagmail.png](/images/ovh_correo/pruebagmail.png)