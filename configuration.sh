#!/bin/bash
#Instalación automatizada de Moodle y Airnotifier.

#Instalación de apache y mysql.
apt-get install apache2 mysql-client mysql-server php5
apt-get install graphviz aspell php5-pspell php5-curl php5-xmlrpc php5-ldap

#Reiniciar apache.
service apache2 restart

#Instalación de git.
apt-get install git-core

#Descarga de moodle.
cd /opt
git clone git://git.moodle.org/moodle.git
cd moodle
git branch -a
git branch --track MOODLE_29_STABLE origin/MOODLE_29_STABLE
git checkout MOODLE_29_STABLE

#Copia de repositorio descargado a /var/www/html
cp -R /opt/moodle /var/www/html/
mkdir /var/moodledata
chown -R www-data /var/moodledata
chmod -R 777 /var/moodledata
chmod -R 0755 /var/www/html/moodle

#Configuración de mysql.
echo "default-storage-engine = innodb" >> /etc/mysql/my.cnf

#Reiniciar mysql
service mysql restart

#Creación de la base de datos.
echo -n "Introduzca el nombre de la base de datos:"
read basedatos
echo "CREATE DATABASE $basedatos DEFAULT CHARACTER SET UTF8 COLLATE UTF8_UNICODE_CI;" | mysql -u root -p

#Crear un usuario nuevo en la base de datos.
echo -n "Introduzca el nombre de usuario de la base de datos: "
read user
echo -n "Introduzca la contraseña del usuario de la base de datos: "
read pass
echo "CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass';" | mysql -u root -p

#Añadir privilegios al usuario creado.
echo "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER ON $basedatos.* TO $user@localhost IDENTIFIED BY '$pass';"| mysql -u root -p

#Completando la configuración de moodle.
chmod -R 777 /var/www/html/moodle

#Instalación de airnotifier.
apt-get install python-pip python-dev build-essential mongodb
mkdir -p /var/airnotifier/pemdir
cd
git clone git://github.com/airnotifier/airnotifier.git airnotifier
cd airnotifier
pip install -r requirements.txt
cp airnotifier.conf-sample airnotifier.conf
python install.py
python airnotifier.py >>airnotifier.log 2>>airnotifier.err
cd /var/lib/mongodb
echo 'db.applications.insert({"_id":"3500","connections" : 1,"gcmapikey" : "AIzaSyC0eyAZj4mnSLKH8ZeXQVz_yOk_lJVAd5w","description" : "mongoDB ejemplo2","blockediplist" : "","clickatellappid" : "","environment" : "sandbox","gcmprojectnumber" : "961862700696","shortname" : "ejemplo4","enableapns" : 0,"fullname" : "commoejemplo4","clickatellpassport" : "","clickatellusername" : ""})'| mongo airnotifier