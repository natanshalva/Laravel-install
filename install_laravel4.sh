#!/bin/sh
#
#   This script will download and install Laravel 4 ( with Generator Guard and Profiler ) 
# 
#   platform: UNIX
#  
#   Written by Natan Shalva   20.4.2013 
#    
#   

# install laravl 4 


printf "\n \n Welcome, You are about to download and install Laravel 4. \n \n";

cd /var/www/

printf "Please type in directory name for your new Laravel 4 website project  \n\r ( the dir will be created under /var/www/ )\n\r"
read _dir
if [ -d /var/www/$_dir ] ; then

    printf "\n \n The directory: $_dir already exist. would you like to delete it ? (y/n) \n\r" ;
    read answer
    if [ $answer = y ] ; then
        rm -rf $_dir ;
    else 
        return
    fi  
fi


printf "\n \n Creating new dir name: $_dir \n \n\r"
cd /var/www/
mkdir $_dir

printf "\n Assigning $_dir 777 permissions \n\r "
chmod -R 777 $_dir

cd $_dir; 

pwd ;

printf "\n install composer \n"
curl -s https://getcomposer.org/installer | php
php composer.phar install



#
# The Laravel download link
#


_laravel4="https://github.com/laravel/laravel/archive/develop.zip"

printf "\n Fetching Laravl 4 from: $_laravel4 \n please select y to proceed n to select a different source: (y/n)\n\r"

read answer
if [ $answer = n ] ; then
    printf "\n Please type download link for laravl 4 "
    read _laravel4
fi 

printf "\n Downloading and unzipping Laravel 4\n";
wget $_laravel4 ;
unzip '*.zip' ;


printf "\n Assigning $_dir 777 permissions \n " ;
chmod -R 777 ../$_dir ;


#cd laravel-develop ;
pwd ;
rsync -avz laravel-develop/ ./
printf "\n we are in: " ;
pwd
printf "\n Verifying installation  -  file list: \n" ;
ls -la;

printf "\n Removing zip and laravel-develop folder \n"
rm -rf laravel-develop develop.zip ;

printf "\n Running composer update \n"
if [ -f ./composer.json ] ; then 
		composer update
else 
	printf "\n Oops, can't find composer.json \n";
	# exit the sctipt 
	return;
fi	

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

printf "\n \n Create database with the same name as the file directory (y/n) \n\r"
read answer
if [ $answer = y ] ; then

    printf "\n Enter mysql user name \n\r"
    read _user

    printf "\n Enter mysql password \n\r"
    read _pass

    if [ -d /var/lib/mysql/$_dir ] ; then

        printf "\n Database already exists, whould you like to delete it and create new one ? (y/n) \n\r"
        read answer
        if [ $answer = y ] ; then
        	mysqladmin -u $_user -p"$_pass" drop $_dir ;
        	printf "\n Deleting database \n"
        	printf "\n Creating new database $_dir \n "
        	mysqladmin -u $_user -p"$_pass" create $_dir
        fi

    else
        printf "\n Creating database $_dir \n "
        mysqladmin -u $_user -p"$_pass" create $_dir
    fi

    printf  "\n \n ---------- Database installation complete --------------- \n "




printf "\n Configuring database name and the user in Laravl 4 config ./app/config/database.php"

printf "\n create ./app/config/database.php.orig file \n "
mv ./app/config/database.php ./app/config/database.php.orig ;

 sed "s/'database'  => 'database'/'database'  => '$_dir'/g  
 	  s/'username'  => 'root'/'username'  => '$_user'/g  
	  s/'password'  => ''/'password'  => '$_pass'/g"  ./app/config/database.php.orig > ./app/config/database.php



printf "\n Installing migrate \n "
eval "php artisan migrate:install"

fi 

# 
#  Generator Guard and Profiler
# 

printf "\n would you like to install the following packages ? \n\n

         Generator - by the one and the only Jeffry way \n\n
         You can see it in gitHub: https://github.com/JeffreyWay/Laravel-4-Generators

         Guard - by the one and the only Jeffry way \n\n
         You can see it in gitHub: https://github.com/JeffreyWay/Laravel-Guard

         The Profiler - written by Loic Sharma \n\n\
         You can see it in gitHub: https://github.com/loic-sharma/profiler \n\n\

         yes or no (y/n) \n\r" 

read answer
if [ $answer = y ] ; then

    printf "\n Configure Generator Profiler Guard in composer.json \n "
    mv ./composer.json ./composer.json.orig

    sed "s|\"laravel/framework\": \"4.0.*\"|\"laravel/framework\": \"4.0.*\",|" ./composer.json.orig > ./composer.json.orig2

    sed "4 i\ \"way/generators\": \"dev-master\", \n        \"loic-sharma/profiler\": \"1.0.*\",\n        \"way/guard-laravel\": \"dev-master\"  "  ./composer.json.orig2 > ./composer.json

    printf "\n Run composer update \n "
    composer update

    printf "\n Configure Generator Profiler Guard in /app/config/app.php \n "

    printf "\n create ./app/config/app.php.orig file \n"
    mv ./app/config/app.php ./app/config/app.php.orig ;
    sed "115 i\ 'Way-Generators-GeneratorsServiceProvider',\n \'Profiler-ProfilerServiceProvider',\n\'Way-Console-GuardLaravelServiceProvider',  "  ./app/config/app.php.orig > ./app/config/app.php.orig2

    sed 's/Way-Generators-GeneratorsServiceProvider/Way\\Generators\\GeneratorsServiceProvider/g  
      s/Profiler-ProfilerServiceProvider/Profiler\\ProfilerServiceProvider/g  
      s/Way-Console-GuardLaravelServiceProvider/Way\\Console\\GuardLaravelServiceProvider/g ' ./app/config/app.php.orig2 > ./app/config/app.php 
    
    rm ./app/config/app.php.orig2 ;

    printf "\n Assign $_dir 777 permissions \n " ;
    chmod -R 777 ../$_dir ;


    printf  "\n \n---------- Generator, Profiler and Guard installation complete   --------------- \n "

    printf "\n Would you like to create packages info and instruction file ? (y/n) \n\r"
    read answer
    if [ $answer = y ] ; then

    printf  "\n\n Generator - by the one and the only Jeffry way \n\n
         gitHub: https://github.com/JeffreyWay/Laravel-4-Generators

         Guard - by the one and the only Jeffry way \n\n
         gitHub gitHub: https://github.com/JeffreyWay/Laravel-Guard

         The Profiler - written by Loic Sharma \n\n\
         gitHub: https://github.com/loic-sharma/profiler \n\n\ " > packages.info
    
        printf  "\n packages.info created at project root directory"

    fi
fi 

# istall git 

printf "\n \n install git \n "
git init

printf "\n \n Adding and commiting project to git  \n "
git add -A
git commit -am"Good Start"

printf "\n \n Project commited \n "


# virtual host

printf "\n \n \n Would you like to create VirtualHost config for Laravl 4 ? (y/n) \n\r"
read answer

if [ $answer = y ] ; then

virtualhost=y

    printf "\n Creating virtual host \n "

    printf "\n Type in user (if you don't know what to write here the it is probably root ) \n\r"
    read usr

homedir=$_dir ;

    printf "\n Type in domain ( exp: laravl.local ) \n\r "
    read sn


    # Create a directory for your apache errors log 
    mkdir /var/log/apache2/$sn/


    # Create  VirtualHost configuration file in /etc/apache2/site-available/
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
        printf "Adding $sh to /etc/hosts "  
        printf "127.0.0.1 $sn" >> /etc/hosts
    fi

    # Enable site 
    a2ensite $sn

    # Reload Apache2
    /etc/init.d/apache2 reload

fi

printf "\n \n"
banner "All good"
printf "\n \n"

printf "\n \n ************ All GOOD! **************  \n \n" ;

if [ $virtualhost = y ] ; then
printf "\n \n New Laravel project can be viewed at:  \n http://$_dir  \n \n" ;
fi

printf "\n \n Script written by Natan Shalva \n to promote peace love and understanding \n \n" 
printf "\n \n Enjoy your new Laravel 4 ... \n \n"




