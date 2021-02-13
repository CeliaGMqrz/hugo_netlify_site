---
title: "Servidor de Correos. Postfix (IV). Webmail"
date: 2021-01-25T17:15:21+01:00
draft: false
toc: false
images:
tags: ['servidor de correos','dovecot', 'webmail']
---

## Descripción

(Tarea 10 y 12)

Vamos a instalar un webmail () para gestionar el correo del equipo mediante una interfaz web. Recibo y envío de correos.


## Instalar webmail RoundCube


RoundCube es un cliente de correo electrónico IMAP, de código abierto y escrito en PHP. Para instalar este webmail deberemos de tener en funcionamiento un servidor de correos, en este caso usaremos **postfix**. Un servidor web en este caso tenemos a **Nginx**. Tendremos que tener instalado PHP 5.4 o superior.


* Instalación de extensiones php 

```sh
sudo apt install nginx php-cgi php-fpm php-pear php-mysql php-imap php-memcache memcached php-pear php-intl
```

* Instalar roundcube, aceptaremos la configuracion por defecto e indicaremos la contraseña para nuestra aplicacion

```sh

```


* Crear usuario

```sh
GRANT ALL PRIVILEGES ON roundcube.* TO roundcube@"localhost" IDENTIFIED BY 'roundcube';
```


```sh
sudo certbot -d correo.iesgn05.es --agree-tos -m debian@iesgn05.es
```

```sh
debian@kiara:~$ sudo sed -i 's/;date.timezone =/date.timezone = Europe\/Amsterdam/g' /etc/php/7.3/fpm/php.ini
debian@kiara:~$ sudo systemctl restart php7.3-fpm
debian@kiara:~$ sudo certbot -d correo.iesgn05.es --agree-tos -m debian@iesgn05.es
Saving debug log to /var/log/letsencrypt/letsencrypt.log

How would you like to authenticate and install certificates?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: Apache Web Server plugin (apache)
2: Nginx Web Server plugin (nginx)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 2
Plugins selected: Authenticator nginx, Installer nginx
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for correo.iesgn05.es
Waiting for verification...
Cleaning up challenges
Deploying Certificate to VirtualHost /etc/nginx/sites-enabled/mail.iesgn05.com.conf

Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
new sites, or if you're confident your site works on HTTPS. You can undo this
change by editing your web server's configuration.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 2
Redirecting all traffic on port 80 to ssl in /etc/nginx/sites-enabled/mail.iesgn05.com.conf

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations! You have successfully enabled https://correo.iesgn05.es

You should test your configuration at:
https://www.ssllabs.com/ssltest/analyze.html?d=correo.iesgn05.es
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/correo.iesgn05.es/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/correo.iesgn05.es/privkey.pem
   Your cert will expire on 2021-05-13. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


```