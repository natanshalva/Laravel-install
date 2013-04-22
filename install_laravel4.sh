#!/bin/sh


# install laravl 4 

# The laravel download link 
_laravel4="https://github.com/laravel/laravel/archive/develop.zip"


echo "We are going to download and install Laravel 4 from $_laravel4";

echo "Please write your new Laravel site dir ( it will be create in /var/www/)"
read _dir
echo "creating new dir name: $_dir"
cd /var/www/
mkdir $_dir

echo "Give the $_dir 777 permissions "
chmod -R 777 $_dir

cd $_dir; 

echo "we are in the dir"
pwd ;

echo "install composer"
curl -s https://getcomposer.org/installer | php
php composer.phar install

echo "downloading Laravel 4 and unzip";
wget $_laravel4 ;
unzip '*.zip' ;



echo "Give the $_dir 777 permissions " ;
chmod -R 777 ../$_dir ;


echo "move the unzip up one level" ;
#cd laravel-develop ;
pwd ;
rsync -avz laravel-develop/ ./
echo "files in: " ;
pwd
ls -la;

echo "remove zip and laravel-develop folder"
rm -rf laravel-develop develop.zip ;

echo "composer update"
if [ -f ./composer.json ] ; then 
		composer update
else 
	echo "can't find composer.json file";
	# exit the sctipt 
	return;
fi	

echo "we are in ";
pwd ;

	   
if [ -f ./artisan ] ; then 
	echo "php artisan key" ;
	eval "php artisan key:generate"  
else 
	echo "Can't find artisan file.";
	# exit the sctipt 
	return;
fi	


# create database 


echo "create database with the same name as the file dir"
echo "Enter your mysql user"
read _user

echo "Enter your mysql user password"
read _pass

if [ -d /var/lib/mysql/$_dir ] ; then

    echo "Database exist, whould you like to delete it and create new one ? (y/n)"
    read answer
    if [ $answer = y ] ; then
    	mysqladmin -u $_user -p"$_pass" drop $_dir ;
    	echo "database delete"
    	echo "Create the new database $_dir"
    	mysqladmin -u $_user -p"$_pass" create $_dir
    fi

else
    echo "Create the database $_dir"
    mysqladmin -u $_user -p"$_pass" create $_dir
fi

echo -e  "\n---------- Good, we finish with the database issues  --------------- "

echo -e "\n Update the database name and the user in Laravl 4 config ./app/config/database.php"

echo "create ./app/config/database.php.orig file"
mv ./app/config/database.php ./app/config/database.php.orig ;

 sed "s/'database'  => 'database'/'database'  => '$_dir'/g  
 	  s/'username'  => 'root'/'username'  => '$_user'/g  
	  s/'password'  => ''/'password'  => '$_pass'/g"  ./app/config/database.php.orig > ./app/config/database.php



ehco "Install migrate"
eval "php artisan migrate:install"

echo -e "whould you like to install the following packages ? \n\n

         Generator - by the one and the only Jeffry way \n\n
         You can see it in gitHub: https://github.com/JeffreyWay/Laravel-4-Generators

         Guard - by the one and the only Jeffry way \n\n
         You can see it in gitHub: https://github.com/JeffreyWay/Laravel-Guard

         The Profiler - written by Loic Sharma \n\n\
         You can see it in gitHub: https://github.com/loic-sharma/profiler \n\n\

         yes or no (y/n)" 

read answer
if [ $answer = y ] ; then

    echo "Update the Generator Profiler Guard to the file composer.json "
    mv ./composer.json ./composer.json.orig

    sed "s|\"laravel/framework\": \"4.0.*\"|\"laravel/framework\": \"4.0.*\",|" ./composer.json.orig > ./composer.json.orig2

    sed "4 i\ \"way/generators\": \"dev-master\", \n        \"loic-sharma/profiler\": \"1.0.*\",\n        \"way/guard-laravel\": \"dev-master\"  "  ./composer.json.orig2 > ./composer.json

    echo -e "run composer update"
    composer update

    echo "Update the Generator Profiler Guard to the file /app/config/app.php "

    echo "create ./app/config/app.php.orig file"
    mv ./app/config/app.php ./app/config/app.php.orig ;
    sed "115 i\ 'Way-Generators-GeneratorsServiceProvider',\n \'Profiler-ProfilerServiceProvider',\n\'Way-Console-GuardLaravelServiceProvider',  "  ./app/config/app.php.orig > ./app/config/app.php.orig2

    sed 's/Way-Generators-GeneratorsServiceProvider/Way\\Generators\\GeneratorsServiceProvider/g  
      s/Profiler-ProfilerServiceProvider/Profiler\\ProfilerServiceProvider/g  
      s/Way-Console-GuardLaravelServiceProvider/Way\\Console\\GuardLaravelServiceProvider/g ' ./app/config/app.php.orig2 > ./app/config/app.php 
    
    echo "Give the $_dir 777 permissions " ;
    chmod -R 777 ../$_dir ;


    echo -e  "\n---------- Good, we finish configure the files to work with database and Generator Profiler Guard   --------------- "

fi 



# virtual host

echo "whould you like to create VirtualHost ? (y/n)"
read answer

if [ $answer = y ] ; then

    echo -e "\n create virtual host"

    echo "Enter the user"
    read usr
    echo "Enter web directory"
    read homedir
    echo "Enter domain"
    read sn


    # Create a directory for your apache errors log 
    mkdir /var/log/apache2/$sn/


    # Creation the file with VirtualHost configuration in /etc/apache2/site-available/
    echo "<VirtualHost *:80>
            ServerAdmin webmaster@$sn
            ServerName $sn
            ServerAlias www.$sn

            DocumentRoot /var/www/$homedir/public
            <Directory />
                    Options FollowSymLinks
                    AllowOverride All
            </Directory>
            <Directory /var/www/$homedir >
                    Options Indexes FollowSymLinks MultiViews
                    AllowOverride All
                    Order allow,deny
                    allow from all
            </Directory>

     

            ErrorLog /var/log/apache2/$sn/error.log

            # Possible values include: debug, info, notice, warn, error, crit,
            # alert, emerg.
            LogLevel warn

            CustomLog /var/log/apache2/$sn/access.log combined

      

    </VirtualHost>" > /etc/apache2/sites-available/$sn


    # Add the host to the hosts file
    if [ grep $sn /etc/hosts ] ; then
        echo "the vhost is allready in /etc/hosts "

    else 
        echo "i am adding $sh to /etc/hosts "  
        echo "127.0.0.1 $sn" >> /etc/hosts
    fi

    # Enable the site 
    a2ensite $sn

    # Reload Apache2
    /etc/init.d/apache2 reload

fi


echo -e "\n \n All GOOD!" ;
echo "Enjoy your coding..."
echo "Script by Natan Shalva " 





