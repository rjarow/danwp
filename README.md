# Alpine-NGINX-PHPFPM-Wordpres (x86_64)
[![](https://images.microbadger.com/badges/image/rjarow/alpine-nginx-phpfpm.svg)](https://microbadger.com/images/rjarow/alpine-nginx-phpfpm "Get your own image badge on microbadger.com")

This is a Docker Container that uses alpine 3.6, adds s6 overlay(process manager), installs latest nginx, php-fpm. wp-cli is then installed, downloads Wordpress to /usr/html. 

If the environment variables for database info are passed, it waits for the db instance to become available and then writes the wp-config.php file with that info.

You then can go to the URL where this is pointed to finish up your configuration.

If the environment variables for datanase info are NOT passed,wp-cli simply downloads wordpress and leaves it unconfigured. You can modify the wp-config.php via your bind mount or by entering into the container.

I have also included mysql-client so that you can interact with a MySQL(MariaDB) DB container from within this container.

This has been tested to work with the following MariaDB servers:

* [MariaDB Official ](https://hub.docker.com/_/mariadb/) - Latest
* [rjarow/alpine-mariadb](https://hub.docker.com/r/rjarow/alpine-mariadb/) - Latest



### Prerequisites

Any OS supporting Docker, I prefer Linux.

[Docker](https://www.docker.com/get-docker)


### Installing

Assuming you have Docker configured correctly, simply pull my image.

```
$ docker pull rjarow/danwp
```

### Deploying

There are a few ways to deploy this, I would suggest using the -v volume mount to point to your application that needs to be hosted. The image looks for /usr/html for content.

The following variables are available in the environment.

```
PUID - Process UID - The nginx process will run as this UID in the container. Match this to a host so you can modify files outside the container.

PGID - Same as above but for the Group ID, Usually same as PUID

WORDPRESS_DB_HOST - This is the IP or hostname of the MySQL server you'd like to connect to.

WORDPRESS_DB - This is the database name on the server above, that you'd like to use.

WORDPRESS_DB_USER - This is the MySQL user to be used on the MySQL server above.

WORDPRESS_DB_PASSWORD - This is the password for the user to connect to the server above.
```

Example deployment:
```
docker create --name danwptest -p 80:80 -v $(pwd):/usr/html \ -e PUID=$(id -u) \
-e PGID=$(id -u) \
-e WORDPRESS_DB_HOST=dbinstance \
-e WORDPRESS_DB=db \
-e WORDPRESS_DB_USER=wordpress \
-e WORDPRESS_DB_PASSWORD=dbpassword \
rjarow/alpine-nginx-phpfpm

docker container start danwp
```

I would highly suggest running this behind an nginx reverse proxy, a really easy, automatic one by [jwilder](https://github.com/jwilder/nginx-proxy) is my preferred method.

Example of recommended deployment:
```
docker network create nginx-proxy

docker create -d -p 80:80 --name nginx-proxy \
--net nginx-proxy \
-v /var/run/docker.sock:/tmp/docker.sock \
jwilder/nginx-proxy

docker create --name yourdomain_db \
--net nginx-proxy \
-e PUID=$(id -u) \
-e PGID=$(id -u) \
-e MYSQL_ROOT_PASSWORD=rootpass \
-e MYSQL_DATABASE=wordpress \
-e MYSQL_USER=wordpress \ 
-e MYSQL_PASSWORD=password \
-v $(pwd)/db:/var/lib/mysql \
rjarow/alpine-mariadb

docker create --name yourdomain_wp \
--net nginx-proxy \
-e VIRTUAL_HOST=yourdomain.com \
-e PUID=$(id -u) \
-e PGID=$(id -u) \
-e WORDPRESS_DB_HOST=yourdomain_db \
-e WORDPRESS_DB=wordpress \
-e WORDPRESS_DB_USER=wordpress \
-e WORDPRESS_DB_PASSWORD=password \
rjarow/alpine-nginx-phpfpm

docker start nginx-proxy
docker start yourdomain_db
docker start yourdomain_wp

```
You can then run other domains behind this same proxy just by specifying the VIRTUAL_HOST variable when creating/running your docker container. 

With that you can run multiple domains on the same docker host. In essence shared wordpress hosting.

Check out my ansible scripts to automate this entire process [here (coming soon!)](comingsoon!)

Additional PHP Modules:

```

List of available modules in Alpine Linux, not all these are installed.

In order to install a php module do, (leave out the version number i.e. -5.6.11-r0

docker container exec <image_name> apk add <pkg_name>
docker container restart <image_name>
Example:

docker container exec <image_name> apk add php7-soap
docker container restart <image_name>
php7-common
php7-pdo_sqlite
php7-pear
php7-ftp
php7-imap
php7-mysqli
php7-json
php7-mbstring
php7-soap
php7-litespeed
php7-sockets
php7-bcmath
php7-opcache
php7-dom
php7-zlib
php7-gettext
php7-fpm
php7-intl
php7-openssl
php7-session
php7-mcrypt
php7-pdo_mysql
php7-embed
php7-xmlrpc
php7-wddx
php7-dba
php7-ldap
php7-xsl
php7-exif
php7-pdo_dblib
php7-bz2
php7-pdo
php7-pspell
php7-sysvmsg
php7-gmp
php7-apache2
php7-pdo_odbc
php7-shmop
php7-ctype
php7-phpdbg
php7-enchant
php7-sysvsem
php7-sqlite3
php7-odbc
php7-pcntl
php7-calendar
php7-xmlreader
php7-snmp
php7-zip
php7-posix
php7-iconv
php7-curl
php7-doc
php7-gd
php7-xml
php7-dev
php7-cgi
php7-sysvshm
php7-pgsql
php7-tidy
php7-pdo_pgsql
php7-phar
php7-mysqlnd
```

## Built With

* [Atom](https://atom.io/) - My favorite editor
* [Docker](https://docker.com) - Obviously?
* [Alpine](alpinelinux.org) - The tiny linux!
* [s6-overlay](https://github.com/just-containers/s6-overlay) - Making Docker play nice with processes.
* [Nginx](https://nginx.org/) - The webserver
* [PHP-FPM](https://php-fpm.org/) - PHP Support

## Authors

*Initial work* - [rjarow](https://github.com/rjarow)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Everyone making beautiful efficient Docker Images
* Hi Mom!

