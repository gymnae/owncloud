#!/bin/sh

#optimize www.conf of php
sed -i "s/pm.max_children = .*/pm.max_children = 100/" /etc/php7/php-fpm.d/www.conf
sed -i "s/pm.start_servers = .*/pm.start_servers = 2/" /etc/php7/php-fpm.d/www.conf
sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = 1" /etc/php7/php-fpm.d/www.conf
sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = 5/" /etc/php7/php-fpm.d/www.conf
sed -i "s/;pm.max_requests = 500/pm.max_requests = 400/" /etc/php7/php-fpm.d/www.conf

# optimize php.ini
sed -i "s/output_buffering =.*/output_buffering = Off/" /etc/php7/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 1800/" /etc/php7/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php7/php.ini
sed -i "s/post_max_size =.*/post_max_size = 4G/" /etc/php7/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 4G/" /etc/php7/php.ini
sed -i "s/max_file_uploads =.*/max_file_uploads = 100/" /etc/php7/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/\Berlin/" /etc/php7/php.ini
sed -i "s/;session.cookie_secure.*/session.cookie_secure = True/" /etc/php7/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php7/php.ini
sed -i "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" /etc/php7/php.ini
sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php7/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php7/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/" /etc/php7/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=1/" /etc/php7/php.ini
sed -i "s/;opcache.save_comments=.*/opcache.save_comments=1/" /etc/php7/php.ini
echo "cgi.fix_pathinfo = 0" >>  /etc/php7/php.ini

# needed for some apps, which don't set x-frame themselves. potential security risk
#sed -i -e"s/header('X-Frame-Options: .*/header('X-Frame-Options: ALLOW');/" /usr/share/webapps/nextcloud/lib/private/legacy/response.php

# deal with the weird alpine packaging of some nextcloud packages
ln -s /usr/share/doc/nextcloud/core/doc/ /usr/share/webapps/nextcloud/core/doc

# expose config directory
[ ! -d /media/owncloud/config ] \
      && mkdir -p /media/owncloud/config \
      && chown -R nginx:www-data /media/owncloud/config \
      && chmod -R 0770 /media/owncloud/config
[ -d /usr/share/webapps/nextcloud/config ] && rm -rf /usr/share/webapps/nextcloud/config
ln -s /media/owncloud/config /usr/share/webapps/nextcloud/config
ln -s /media/owncloud/apps /usr/share/webapps/nextcloud/apps2

# create default config.php
[ ! -f /media/owncloud/config/config.php ] \
      && mv /tmp/config.php /media/owncloud/config/config.php \
      && chown nginx:www-data /media/owncloud/config/config.php

# copy owncloud autoconfig.php
[ "`grep "'installed' => false" /media/owncloud/config/config.php`" != "" ] \
      && [ -f /tmp/autoconfig.php ] \
      && mv /tmp/autoconfig.php /media/owncloud/config/autoconfig.php \
      && chown nginx:www-data /media/owncloud/config/autoconfig.php

# owncloud data directory
[ ! -d /media/owncloud/data ] \
      && mkdir -p /media/owncloud/data \
      && chown -R nginx:www-data /media/owncloud/data \
      && chmod -R 0770 /media/owncloud/data      

# owncloud app directory
[ ! -d /media/owncloud/apps ] \
      && mkdir -p /media/owncloud/apps \
      && chown -R nginx:www-data /media/owncloud/apps \
      && chmod -R 0770 /media/owncloud/apps


# owncloud log directory
[ ! -d /media/owncloud/logs/owncloud ] \
      && mkdir -p /media/owncloud/logs/owncloud \
      && chown nginx:www-data /media/owncloud/logs/owncloud \
      && chmod 0770 /media/owncloud/logs/owncloud
      
# create cronjob for nextcloud and run crond
(crontab -u nginx -l; echo "*/15  *  *  *  * php -f /usr/share/webapps/nextcloud/cron.php") | crontab -u nginx -
crond -b -l 0 -L /var/log/cron.log

# only needed, if you don't have redis as a server  start redis and make it run as deamon
#mkdir -p /media/owncloud/cache
#redis-server --dir /media/owncloud/cache --appendonly yes --daemonize yes

# start php-fpm
mkdir -p /media/owncloud/logs/php-fpm
php-fpm7

# start nginx
mkdir -p /media/owncloud/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx 
nginx
