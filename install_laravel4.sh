#!/bin/sh


# install laravl 4 

# The laravel download link 
_laravel4="https://github.com/laravel/laravel/archive/develop.zip"



printf "\n \n We are going to download and install Laravel 4 from $_laravel4 \n \n";


printf "Please write your new Laravel site dir ( it will be create in /var/www/ )"
read _dir


if [ -d /var/www/$_dir ] ; then

    printf "\n \n The directory: $_dir already exist. would you like to delete it ? (y/n) \n \n" ;
    read answer
    if [ $answer = y ] ; then
        rm -rf $_dir ;
    else 
        return
    fi  
fi


printf "\n \n creating new dir name: $_dir \n \n"
cd /var/www/
mkdir $_dir

printf "\n Give the $_dir 777 permissions \n "
chmod -R 777 $_dir

cd $_dir; 

printf "\n we are in the dir "
pwd ;

printf "\n install composer \n"
curl -s https://getcomposer.org/installer | php
php composer.phar install

printf "\n downloading Laravel 4 and unzip \n";
wget $_laravel4 ;
unzip '*.zip' ;


printf "\n Give the $_dir 777 permissions \n " ;
chmod -R 777 ../$_dir ;


printf "\n move the unzip up one level \n " ;
#cd laravel-develop ;
pwd ;
rsync -avz laravel-develop/ ./
printf "\n we are in: " ;
pwd
printf "\n Just to test if all good - let's see the list of files: \n" ;
ls -la;

printf "\n remove zip and laravel-develop folder \n"
rm -rf laravel-develop develop.zip ;

printf "\n composer update \n"
if [ -f ./composer.json ] ; then 
		composer update
else 
	printf "\n can't find composer.json file \n";
	# exit the sctipt 
	return;
fi	

printf "\n we are in: ";
pwd ;

	   
if [ -f ./artisan ] ; then 
	printf "\n php artisan key \n" ;
	eval "php artisan key:generate"  
else 
	printf "\n Can't find artisan file. \n";
	# exit the sctipt 
	return;
fi	


# create database 


printf "\n \n create database with the same name as the file dir \n"
printf "\n Enter your mysql user"
read _user

printf "\n Enter your mysql user password"
read _pass

if [ -d /var/lib/mysql/$_dir ] ; then

    printf "\n Database exist, whould you like to delete it and create new one ? (y/n)"
    read answer
    if [ $answer = y ] ; then
    	mysqladmin -u $_user -p"$_pass" drop $_dir ;
    	printf "\n database deleted \n"
    	printf "\n Create the new database $_dir \n "
    	mysqladmin -u $_user -p"$_pass" create $_dir
    fi

else
    printf "\n Create the database $_dir \n "
    mysqladmin -u $_user -p"$_pass" create $_dir
fi

printf  "\n \n ---------- Good, we finish with the database issues  --------------- \n "

printf "\n Update the database name and the user in Laravl 4 config ./app/config/database.php"

printf "\n create ./app/config/database.php.orig file \n "
mv ./app/config/database.php ./app/config/database.php.orig ;

 sed "s/'database'  => 'database'/'database'  => '$_dir'/g  
 	  s/'username'  => 'root'/'username'  => '$_user'/g  
	  s/'password'  => ''/'password'  => '$_pass'/g"  ./app/config/database.php.orig > ./app/config/database.php



printf "\n Install migrate \n "
eval "php artisan migrate:install"

printf "\n would you like to install the following packages ? \n\n

         Generator - by the one and the only Jeffry way \n\n
         You can see it in gitHub: https://github.com/JeffreyWay/Laravel-4-Generators

         Guard - by the one and the only Jeffry way \n\n
         You can see it in gitHub: https://github.com/JeffreyWay/Laravel-Guard

         The Profiler - written by Loic Sharma \n\n\
         You can see it in gitHub: https://github.com/loic-sharma/profiler \n\n\

         yes or no (y/n)" 

read answer
if [ $answer = y ] ; then

    printf "\n Update the Generator Profiler Guard to the file composer.json \n "
    mv ./composer.json ./composer.json.orig

    sed "s|\"laravel/framework\": \"4.0.*\"|\"laravel/framework\": \"4.0.*\",|" ./composer.json.orig > ./composer.json.orig2

    sed "4 i\ \"way/generators\": \"dev-master\", \n        \"loic-sharma/profiler\": \"1.0.*\",\n        \"way/guard-laravel\": \"dev-master\"  "  ./composer.json.orig2 > ./composer.json

    printf "\n run composer update \n "
    composer update

    printf "\n Update the Generator Profiler Guard to the file /app/config/app.php \n "

    printf "\n create ./app/config/app.php.orig file \n"
    mv ./app/config/app.php ./app/config/app.php.orig ;
    sed "115 i\ 'Way-Generators-GeneratorsServiceProvider',\n \'Profiler-ProfilerServiceProvider',\n\'Way-Console-GuardLaravelServiceProvider',  "  ./app/config/app.php.orig > ./app/config/app.php.orig2

    sed 's/Way-Generators-GeneratorsServiceProvider/Way\\Generators\\GeneratorsServiceProvider/g  
      s/Profiler-ProfilerServiceProvider/Profiler\\ProfilerServiceProvider/g  
      s/Way-Console-GuardLaravelServiceProvider/Way\\Console\\GuardLaravelServiceProvider/g ' ./app/config/app.php.orig2 > ./app/config/app.php 
    
    rm ./app/config/app.php.orig2 ;

    printf "\n Give the $_dir 777 permissions \n " ;
    chmod -R 777 ../$_dir ;


    printf  "\n \n---------- Good, we finish configure the files to work with database and Generator Profiler Guard   --------------- \n "

fi 

# istall git 

printf "\n \n install git \n "
git init

printf "\n \n add all files to git and commit them \n "
git add -A
git commit -am"Good Start"

printf "\n \n We have commit all the files \n "


# virtual host

printf "\n \n \n whould you like to create VirtualHost ? (y/n)"
read answer

if [ $answer = y ] ; then

    printf "\n create virtual host \n "

    printf "\n Enter the user (if you don't know what to write here the it is probably root )"
    read usr

    homedir=$_dir ;

    printf "\n Enter domain \n "
    read sn


    # Create a directory for your apache errors log 
    mkdir /var/log/apache2/$sn/


    # Creation the file with VirtualHost configuration in /etc/apache2/site-available/
    printf "<VirtualHost *:80>
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
        printf "the vhost is allready in /etc/hosts "

    else 
        printf "i am adding $sh to /etc/hosts "  
        printf "127.0.0.1 $sn" >> /etc/hosts
    fi

    # Enable the site 
    a2ensite $sn

    # Reload Apache2
    /etc/init.d/apache2 reload

fi

printf "\n \n"
banner "All good"
printf "\n \n"

printf "\n \n ************ All GOOD! **************  \n \n" ;
printf "\n \n Script written by Natan Shalva \n \n" 
printf "\n \n Enjoy your new Laravel 4 ... \n \n"




