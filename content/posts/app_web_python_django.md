---
title: "Instalación de aplicación web CMS python"
date: 2021-01-21T13:04:33+01:00
draft: false
toc: false
images:
tags: ['cms','python','djando','wagtail']
---

![wagtail.png](/images/escenario/django/wagtail.png)

## Objetivo:

En este post vamos a trabajar sobre el entorno de trabajo de openstack nuevamente, el mismo sobre el que tratamos en el blog. 

La máquina virtual sobre la que trabajamos es un Centos 8, nuestro llamado Quijote.

El objetivo es desplegar un CMS python, en este caso wagtail, basado en django.

## 1. Instalación de wagtail.



### Entorno de desarrollo: Creación del entorno virtual.

* Primero tendremos que crear un [entorno virtual](https://github.com/CeliaGMqrz/trabajando_python3_venv) en nuestra máquina anfitriona.


### Instalación y configuracion de wagtail

* Dentro del entorno virtual instalaremos el cms wagtail

```sh
pip install wagtail
```

* Creamos el sitio. En su interior podemos ver que se han creado varios ficheros, entre ellos está el fichero 'requirements.txt' que es el que vamos a usar para instalar los paquetes necesarios

```sh
wagtail start mysite
cd mysite
pip install -r requirements.txt
```

* Ahora vamos a mirar la app, crear el usuario administrador y probar su funcionamiento

```sh
python manage.py migrate
```

```sh
(wagtail) celiagm@debian:~/venv/wagtail/mysite$ python manage.py createsuperuser
Username (leave blank to use 'celiagm'): celiagm
Email address: cgarmai95@gmail.com
Password: 
Password (again): 
The password is too similar to the email address.
Bypass password validation and create user anyway? [y/N]: y
Superuser created successfully.
```

```sh
(wagtail) celiagm@debian:~/venv/wagtail/mysite$ python manage.py runserver
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).
January 21, 2021 - 13:25:24
Django version 3.1.5, using settings 'mysite.settings.dev'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.

```

![wag1.png](/images/escenario/django/wag1.png)

* Nos vamos a **http://127.0.0.1:8000/admin/** en el navegador y metemos las credenciales que hemos configurado anteriormente y nos saldrá la pagina para administrar el sitio web.

![wag2.png](/images/escenario/django/wag2.png)


## 2. Personalización del Sitio Web


He seguido un poco la [documentación de Wagtail](https://docs.wagtail.io/en/stable/getting_started/tutorial.html), para personalizar el sitio web y ahora tiene el siguiente aspecto.

![inicio.png](/images/escenario/django/inicio.png)


Se le ha añadido varios apartados entre ellos un blog, al que se puede acceder añadiendo /blog a la url.

![admin.png](/images/escenario/django/admin.png)

![blog.png](/images/escenario/django/blog.png)



## 3. Copia de seguridad de la base de datos. Repositorio git

Vamos a guardar los ficheros que componen esta aplicación en un repositorio de git y ademas tambien vamos hacer la copia de seguridad de la base de datos y la subiremos al mismo repositorio.

* Creamos un repositorio vacio en el directorio de wagtail, añadimos todo el contenido y lo subimos al repositorio que tenemos creado en git.

```sh
git init
git add *
git commit -am "wagtail"
git remote add origin git@github.com:CeliaGMqrz/wagtail.git
git branch -M main
git push -u origin main
```
* Entramos en el directorio mysite y creamos la copia de seguridad de la base de datos, la añadimos al repositorio y la subimos.

```sh
cd mysite/
python manage.py dumpdata > backup_db.json
git add backup_db.json 
git commit -am "copia de seguridad"
git push
```

## 4. Despliegue de la aplicación (servidor web y base de datos)

### 4.1 Crear un usuario para la base de datos

En el servidor de base de datos (Sancho), mariadb en Ubuntu, vamos a crear otro usuario para que use la aplicacion de wagtail en concreto. Además le daremos privilegios para que pueda operar sin problemas con la app.

```sh
MariaDB [(none)]> CREATE USER 'wagtail'@'10.0.2.4' IDENTIFIED BY 'wagtail';
Query OK, 0 rows affected (0.135 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'wagtail'@'10.0.2.4' IDENTIFIED BY 'wagtail' WITH GRANT OPTION;
Query OK, 0 rows affected (0.010 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.034 sec)

MariaDB [(none)]> quit
Bye

```

Nos aseguramos que las bases de datos están accesibles desde todas las máquinas.

```sh
sudo nano /etc/mysql/my.cnf 
```

Buscamos la siguiente linea y comprobamos que esta de la siguiente forma

```sh
bind-address            = 0.0.0.0
```

### 4.2. Comprobar la conexión remota de quijote a sancho

* Necesitaremos tener instalado un cliente de mariadb en quijote 

```sh
sudo dnf install mariadb
```

* Comprobamos la conexión desde el nuevo usuario 'wagtail'

```sh
[centos@quijote ~]$ sudo su
[root@quijote centos]# mysql -u wagtail -p -h bd.celia.gonzalonazareno.org
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 49
Server version: 10.4.17-MariaDB-1:10.4.17+maria~focal-log mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> quit
Bye

```
### 4.3. Crear la base de datos en Sancho

Necesitamos crear una nueva base de datos en Sancho para poder importar la copia de seguridad de la base de datos del entorno de desarrollo al de producción.

* Crear la nueva base de datos llamada 'wagtail'

```sh
MariaDB [(none)]> create database wagtail;
Query OK, 1 row affected (0.008 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON `wagtatil`.* to 'wagtail'@'10.0.2.4';
Query OK, 0 rows affected (0.006 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
```


### 4.4. Crear entorno virtual e instalar el módulo uwsgi

* Descargamos el paquete necesario para crear el entorno virtual y git para clonar nuestro repositorio. Además instalaremos el módulo wsgi para poder desplegar la app y el compilador.

```sh
sudo dnf install git
sudo dnf install python3
sudo dnf install python3-mod_wsgi
sudo dnf install gcc python3-devel

```
* Clonamos el repositorio en nuestro documenroot 

```sh
[centos@quijote www]$ sudo git clone https://github.com/CeliaGMqrz/wagtail
```

* Creamos el entorno virtual, lo activamos e instalamos los paquetes que están en el fichero requeriments.txt

```sh
python3 -m venv wagtail
```

Activamos el entorno virtual

```sh
[centos@quijote ~]$ source wagtail/bin/activate
(wagtail) [centos@quijote ~]$ 
```
Instalamos los paquetes del fichero requirements y además intalaremos el conector de mariadb con python y el módulo uwsgi

```sh
pip install -r requirements.txt 
pip install uwsgi
pip install mysql-connector-python

```
Comprobamos que estan instalados

```sh
(wagtail1) [centos@quijote ~]$ pip freeze
anyascii==0.1.7
asgiref==3.3.1
beautifulsoup4==4.8.2
certifi==2020.12.5
chardet==4.0.0
Django==3.1.5
django-filter==2.4.0
django-modelcluster==5.1
django-taggit==1.3.0
django-treebeard==4.4
djangorestframework==3.12.2
draftjs-exporter==2.1.7
et-xmlfile==1.0.1
html5lib==1.1
idna==2.10
jdcal==1.4.1
l18n==2020.6.1
mysql-connector-python==8.0.23
openpyxl==3.0.6
Pillow==8.1.0
protobuf==3.14.0
pytz==2020.5
requests==2.25.1
six==1.15.0
soupsieve==2.1
sqlparse==0.4.1
tablib==3.0.0
Unidecode==1.1.2
urllib3==1.26.3
uWSGI==2.0.19.1
wagtail==2.11.3
webencodings==0.5.1
Willow==1.4
xlrd==2.0.1
XlsxWriter==1.3.7
xlwt==1.3.0

```

### 4.5. Configuración de la base de datos

* Editamos el fichero de configuración de wagtail

```sh
sudo nano /var/www/wagtail/mysite/mysite/settings/base.py
```

* Buscamos la linea donde se define las caracteristicas de la base de datos a ala que se va a conectar y lo reemplazamos segun lo siguiente:

```sh
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        "NAME": "wagtail",
        "USER": "wagtail",
        "PASSWORD": "wagtail",
        "HOST": "10.0.1.11",
        "PORT": "",
    }
}
```

### 4.6. Restaurar copia de seguridad de la base de datos

Previamente hemos hecho una copia de seguridad de la base de datos proveniente de el entorno de desarrollo y lo hemos subido a nuestro git. 

Ahora vamos a cargar los datos de esa copia de seguridad para importarlos en la nueva base de datos de mysql. 

Lo haremos desde el entorno virtual

```sh

```