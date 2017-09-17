#!/bin/bash

[ -f /run-pre.sh ] && /run-pre.sh

# Install wp-cli if it doesn't exist.
if [ ! -f /usr/bin/wp ]; then
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp && chmod 755 /usr/bin/wp && chown nginx:nginx /usr/bin/wp
else
  echo "wp-cli already installed"
fi

# If /usr/html/wp-config.php doesn't exist (wordpress not installed) -> take variables from Docker/Compose and create configuration.
if [ ! -f /usr/html/wp-config.php ]; then
  mkdir -p /usr/html
  cd /usr/html
  wp core download --path=/usr/html
else
  echo "WP already installed."
fi

# If variables are set and wp-config.php isn't in place ,create wp-config.php, otherwise leave it be.
if [ -n "$WORDPRESS_DB" ] && [ ! -f /usr/html/wp-config.php ]; then
  /usr/bin/wait-for-it.sh ${WORDPRESS_DB_HOST}:3306 --timeout=60 --strict -- wp config create --dbhost=$WORDPRESS_DB_HOST --dbname=$WORDPRESS_DB --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --path=/usr/html
else
  echo "WP already configured or Environment Variables not set"
fi

# chown /usr/html
chown -R nginx:nginx /usr/html

# Start php-fpm
mkdir -p /usr/logs/php-fpm
php-fpm7

# Start nginx
mkdir -p /usr/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx
nginx
