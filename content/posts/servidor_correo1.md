---
title: "Servidor de Correos. Postfix (I)"
date: 2021-01-22T12:48:10+01:00
draft: false
toc: false
images:
tags: ['servidor correos','spf','mailx','postfix']
---

![postfix.png](/images/ovh_correo/postfix.png) 

## 1. Objetivo.

Instalación y configuración de un servidor de correos en una máquina de OVH, para el dominio **iesgn05**. El nombre del servidor de correo será **mail.iesgn05.es**.

Configurar un registro **SPF**, que es un mecanismo de autenticación que mediante un registro DNS de tipo TXT describe las direcciones IPs y nombres DNS autorizados a enviar correo @DOMINIO. 

## 2. Gestión de correos desde el servidor

### 2.1. Instalación del servidor de correos

Para instalar el servidor de correos vamos a descargar e instalar el paquete `
`postfix` y la utilidad `bsd-mailx` para leer los correos.

```sh
sudo apt-get install postfix bsd-mailx
```

Cuando instalemos postfix, dejaremos la configuración por defecto por el momento, dejando la opción 'Internet Site' y creara la configuración estándar.


### 2.2. Enviar un correo de prueba de local al exterior

Tarea 1: Documenta una prueba de funcionamiento, donde envíes desde tu servidor local al exterior. Muestra el log donde se vea el envío. Muestra el correo que has recibido. Muestra el registro SPF.

* Mandamos el correo de prueba:

```sh
debian@kiara:~$ mail cgarmai95@gmail.com
Subject: Prueba
Hola esto es una prueba
Cc: 

```
* Comprobamos que nos llega el correo

![correo1.png](/images/ovh_correo/correo1.png)

*  Mostramos el log

```sh
debian@kiara:~$ cat /var/log/mail.log 
Jan 25 09:02:52 kiara postfix/postfix-script[27856]: starting the Postfix mail system
Jan 25 09:02:52 kiara postfix/master[27858]: daemon started -- version 3.4.14, configuration /etc/postfix
Jan 25 09:07:03 kiara postfix/pickup[27860]: 3BB6B42306: uid=1000 from=<debian>
Jan 25 09:07:03 kiara postfix/cleanup[27978]: 3BB6B42306: message-id=<20210125090703.3BB6B42306@kiara.iesgn05.es>
Jan 25 09:07:03 kiara postfix/qmgr[27861]: 3BB6B42306: from=<debian@kiara.iesgn05.es>, size=477, nrcpt=3 (queue active)
Jan 25 09:07:03 kiara postfix/local[27980]: 3BB6B42306: to=<Prueba@kiara.iesgn05.es>, orig_to=<Prueba>, relay=local, delay=0.04, delays=0.02/0.01/0/0.01, dsn=5.1.1, status=bounced (unknown user: "prueba")
Jan 25 09:07:03 kiara postfix/local[27982]: 3BB6B42306: to=<Subject:@kiara.iesgn05.es>, orig_to=<Subject:>, relay=local, delay=0.04, delays=0.02/0.02/0/0.01, dsn=5.1.1, status=bounced (unknown user: "subject:")
Jan 25 09:07:03 kiara postfix/smtp[27981]: connect to gmail-smtp-in.l.google.com[2a00:1450:400c:c0a::1a]:25: Network is unreachable
Jan 25 09:07:04 kiara postfix/smtp[27981]: 3BB6B42306: to=<cgarmai95@gmail.com>, relay=gmail-smtp-in.l.google.com[64.233.184.27]:25, delay=0.78, delays=0.02/0.01/0.34/0.42, dsn=2.0.0, status=sent (250 2.0.0 OK  1611565624 i9si3008047wrw.2 - gsmtp)
Jan 25 09:07:04 kiara postfix/cleanup[27978]: 04D5C4231C: message-id=<20210125090704.04D5C4231C@kiara.iesgn05.es>
Jan 25 09:07:04 kiara postfix/qmgr[27861]: 04D5C4231C: from=<>, size=2682, nrcpt=1 (queue active)
Jan 25 09:07:04 kiara postfix/bounce[27984]: 3BB6B42306: sender non-delivery notification: 04D5C4231C
Jan 25 09:07:04 kiara postfix/qmgr[27861]: 3BB6B42306: removed
Jan 25 09:07:04 kiara postfix/local[27980]: 04D5C4231C: to=<debian@kiara.iesgn05.es>, relay=local, delay=0.01, delays=0/0/0/0, dsn=2.0.0, status=sent (delivered to mailbox)
Jan 25 09:07:04 kiara postfix/qmgr[27861]: 04D5C4231C: removed
You have mail in /var/mail/debian

```

* Mostrar registro SPF

![correo2.png](/images/ohv_correo/correo2.png)

### 2.2. Enviar un correo de prueba del exterior a local

Tarea 2: Documenta una prueba de funcionamiento, donde envíes un correo desde el exterior (gmail, hotmail,…) a tu servidor local. Muestra el log donde se vea el envío. Muestra cómo has leído el correo. Muestra el registro MX de tu dominio.


* Enviamos el correo de prueba

![correo3.png](/images/ohv_correo/correo3.png)

* Mostramos el log del envio

```sh
MIME-Version: 1.0
Date: Mon, 25 Jan 2021 10:29:42 +0100
Message-ID: <CA+p9fxpdJwBg_0wsL0kEsC_Q1Qjm6M9SF-YuqqPNDTBTP3w-_g@mail.gmail.com>
Subject: prueba2
From: "Celia García Márquez" <cgarmai95@gmail.com>
To: debian@kiara.iesgn05.es
Content-Type: multipart/alternative; boundary="00000000000087828d05b9b62d12"

--00000000000087828d05b9b62d12
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Esto es una prueba para el servidor de correos

--=20
*Atte. Celia Garc=C3=ADa M=C3=A1rquez*

--00000000000087828d05b9b62d12
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Esto es una prueba para el servidor de correos<br clear=3D=
"all"><div><br></div>-- <br><div dir=3D"ltr" class=3D"gmail_signature" data=
-smartmail=3D"gmail_signature"><div dir=3D"ltr"><i>Atte. Celia Garc=C3=ADa =
M=C3=A1rquez</i></div></div></div>

--00000000000087828d05b9b62d12--
```

* Comprobamos que nos ha llegado el correo, vemos el mendaje con la utilidad `mail`

```sh
Message 1:
From cgarmai95@gmail.com  Mon Jan 25 09:29:54 2021
X-Original-To: debian@kiara.iesgn05.es
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=2rQiNF6LN2Lr26bwdeUaEikIBfAgcj3FFXH0Jwihfd0=;
        b=mxEmJ7xX6+3hwa9oh/C0jAuSmHaXSiZ4UwVXhpHVriXRCF9qg+Qq3x2VOFvBgy2Ooe
         BSz+PStpArCrP6s4td7Rm6jl88EiePiFXW1ERJU3Fos6lSiQvh/a3J+RCcXuznQtn/Pk
         mvf5N93ZrW7ejbME4c82rtZCjJw5wwNp1U4ocJbAod38fTf263jsakmuEmUIKBo+S19S
         qXkPc1t4yHrgeXlYMBGrlibiCSsQRXexbgSbLZ8KZ+BdGFqBxzWhY7EUD60USSJjw+j7
         GUDk9jGxtB2M/mQcdVEjKwgZz+11n7oTCclN2C7mjof3+/1TrTbwY+l+h0exVa+0EC8O
         +e7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=2rQiNF6LN2Lr26bwdeUaEikIBfAgcj3FFXH0Jwihfd0=;
        b=tAcv7LMfoO0GSNPm5lHJWBHEA9Y/Tr+uNvPKO3Mq+eGLAizzzeN5Z8XSUIMNcJQgIA
         FhQL6z3OperopA3ufBP5JjxHFGUNYOczPuc+ynqJY/6nkKVVvMktP/sEVOzSa3lTlu/A
         9P8XMeZ22wko4nNnB8h4YX80VhtiBRL/gHNczQ7BC+hbAP/abP8TOyiSyliALVhZHAmK
         urTIE7Opl5WFpFXIBjyUaO3aD/9D65lbIczckdT7iUg3NO44Ix7OUOH6vLs3TPuvVTk3
         lhMTTgbY0vpn5xY9NM3zhzjbhSk6JSKoWtrR+ZtLAjCMEWAWqbUsl0WLai0WlGOo2he0
         qkVw==
X-Gm-Message-State: AOAM530XD7PUhxVlbeMUpqmYiIlmOrWikb2sl9UUcFPZD1/O0JGQecc1
        1lceXgI6W+g7Ttmc95emhj6zN2pq0Mx9BB3dak/zFBUTGvs=
X-Google-Smtp-Source: ABdhPJx5I5LePunEuUcS/aU4J+C8LRdt80m6YPgIPai/SYaXIZaL3YrJTLk24gmMDM39Z5kaI6bYTp4clDMwry5+Clg=
X-Received: by 2002:a9d:20a8:: with SMTP id x37mr825585ota.62.1611566992979;
 Mon, 25 Jan 2021 01:29:52 -0800 (PST)
MIME-Version: 1.0
From: =?UTF-8?Q?Celia_Garc=C3=ADa_M=C3=A1rquez?= <cgarmai95@gmail.com>
Date: Mon, 25 Jan 2021 10:29:42 +0100
Subject: prueba2
To: debian@kiara.iesgn05.es
Content-Type: multipart/alternative; boundary="00000000000025fb9b05b9b62e3d"

--00000000000025fb9b05b9b62e3d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Esto es una prueba para el servidor de correos

--=20
*Atte. Celia Garc=C3=ADa M=C3=A1rquez*

--00000000000025fb9b05b9b62e3d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Esto es una prueba para el servidor de correos<br clear=3D=
"all"><div><br></div>-- <br><div dir=3D"ltr" class=3D"gmail_signature" data=
-smartmail=3D"gmail_signature"><div dir=3D"ltr"><i>Atte. Celia Garc=C3=ADa =
M=C3=A1rquez</i></div></div></div>


```

* Registro MX de mi dominio

![correo4.png](/images/ovh_correo/correo4.png)