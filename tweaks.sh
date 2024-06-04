#!/bin/bash

# make the following commands not fail the script if they fail
set +e

# remove unnecessary src directory when the container is running
rm -rf /usr/src/nextcloud

# start with a fixed amount of max children, then collect data for 24hrs to adjust to a good setting later
# calculate following https://www.c-rieger.de/nextcloud-installationsanleitung-apache2/#Installation%20PHP%208.0 howto
# but modified to use only 80% of allocated ram
AvailableRAM=$(awk '/MemAvailable/ {printf "%d", ($2/1024)*0.8}' /proc/meminfo)
AverageFPM=$(ps --no-headers -o 'rss,cmd' -C php-fpm | awk '{ sum+=$1 } END { printf ("%d\n", sum/NR/1024,"M") }')
# set initial children at a fixed number
FPMS=75
# set initial children as a ram based calculat ion
#FPMS=$((AvailableRAM/AverageFPM))
PMaxSS=$((FPMS*2/3))
PMinSS=$((PMaxSS/2))
StartS=$(((PMaxSS+PMinSS)/2))
# sed results into two locations, because i don't know which one stick

sed -i 's/pm=.*/pm=static/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
sed -i 's/pm.max_children=.*/pm.max_children='$FPMS'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
echo 'pm.start_servers='"$StartS" >> ${PHP_INI_DIR}/conf.d/nextcloud.ini
echo 'pm.min_spare_servers='"$PMinSS" >> ${PHP_INI_DIR}/conf.d/nextcloud.ini
echo 'pm.max_spare_servers='"$PMaxSS" >> ${PHP_INI_DIR}/conf.d/nextcloud.ini
sed -i 's/memory_limit=.*/memory_limit='"$AvailableRAM"M'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
sed -i 's/upload_max_filesize=.*/upload_max_filesize='"$AvailableRAM"M'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
sed -i 's/post_max_size=.*/post_max_size='"$AvailableRAM"M'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
# no output compression because I compress via reverse proxy
echo 'zlib.output_compression=Off' >> ${PHP_INI_DIR}/conf.d/nextcloud.ini
# static because I fix the max children to a number for now
echo 'pm = static' >> ${PHP_INI_DIR}/conf.d/nextcloud.ini

sed -i 's/pm =.*/pm = static/' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/pm.max_children =.*/pm.max_children = '$FPMS'/' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/pm.start_servers =.*/pm.start_servers = '$StartS'/' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = '$PMinSS'/' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = '$PMaxSS'/' /usr/local/etc/php-fpm.d/www.conf
#echo 'php_admin_value[session.cookie_samesite] = "None"' >> /usr/local/etc/php-fpm.d/www.conf

## attempt to force nextcloud to create cookies with SameSite=none instead of Lax for SSO reasons
# sed -i "s/'samesite' => .*/'samesite' => 'None',/g" /var/www/html/lib/private/Session/CryptoWrapper.php
# sed -i "s/cookie_samesite' => .*/cookie_samesite' => 'None'];/" /var/www/html/lib/private/Session/Internal.php

# add values to env to make them surely stick
export PHP_PM_MAX_CHILDREN=$FPMS
export PHP_MEMORY_LIMIT=$AvailableRAM
export PHP_UPLOAD_LIMIT=$AvailableRAM

# server tuning according to https://docs.nextcloud.com/server/26/admin_manual/installation/server_tuning.html#enable-php-opcache
sed -i  's/opcache.jit_buffer_size=.*/opcache.jit_buffer_size=256M/' ${PHP_INI_DIR}/conf.d/opcache-recommended.ini
sed -i  's/opcache.memory_consumption=.*/opcache.memory_consumption=512M/' ${PHP_INI_DIR}/conf.d/opcache-recommended.ini

## have php-fpm listen on a unix socket
# mkdir -p /var/run/php-fpm
# sed -i  's;listen =.*;listen = /var/run/php-fpm/php-fpm.sock;' /usr/local/etc/php-fpm.d/zz-docker.conf
# echo 'listen.owner = www-data
# listen.group = www-data' >> /usr/local/etc/php-fpm.d/zz-docker.conf

# tune the postgreSQL php config
rm ${PHP_INI_DIR}/conf.d/docker-php-ext-pdo_pgsql.ini
echo "extension=pdo_pgsql.so

[PostgresSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = 1
pgsql.max_links = 1
pgsql.ignore_notice = 0
pgsql.log_notice = 0"  >> ${PHP_INI_DIR}/conf.d/docker-php-ext-pdo_pgsql.ini

# use redis for session locking
# requires redis to be installed and configured to offer unix socket
# requires unix socket to be mounted in nextcloud container
echo 'redis.session.locking_enabled=1
redis.session.lock_retries=-1
redis.session.lock_wait_time=10000
session.save_handler = redis
session.save_path = "unix:///run/redis-socket/redis.sock?persistent=1&weight=1&database=0"' >> ${PHP_INI_DIR}/conf.d/docker-php-ext-redis.ini
## not needed anymore?
# kill -USR2 $(pidof php-fpm)

## hacks below commented out because nextcloud internal encryption is deactivated and replaced with rclone
## mounting an encrypted share
# add hacks to enable preview generation and proper cron jobs even if encryption is enabled
# sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/custom_apps/previewgenerator/lib/Command/PreGenerate.php
# sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/custom_apps/previewgenerator/lib/Command/Generate.php
# sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/custom_apps/memories/lib/Command/Index.php
# sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/apps/previewgenerator/lib/Command/PreGenerate.php
# sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/apps/previewgenerator/lib/Command/Generate.php#
# sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/apps/memories/lib/Command/Index.php

# give access to the intel iGPU transcoding device to www-data
addgroup --gid 486 --quiet --system render
GID=`stat -c "%g" /dev/dri/renderD128`
groupadd -g $GID render2 || true
GROUP=`getent group $GID | cut -d: -f1`
usermod -aG $GID www-data
usermod -aG render www-data

# install intel driver for amd64
apt update && apt install -y intel-media-va-driver-non-free

# Start a subshell or background shell
(
  # Sleep for 24 hours
  sleep 86400
  # Second set of commands
  echo "Running second set of commands 24 hours later"
  # calculate following https://www.c-rieger.de/nextcloud-installationsanleitung-apache2/#Installation%20PHP%208.0 howto
  AvailableRAM=$(awk '/MemAvailable/ {printf "%d", ($2/1024)*0.8}' /proc/meminfo)
  AverageFPM=$(ps --no-headers -o 'rss,cmd' -C php-fpm | awk '{ sum+=$1 } END { printf ("%d\n", sum/NR/1024,"M") }')
  FPMS=$((AvailableRAM/AverageFPM))
  PMaxSS=$((FPMS*2/3))
  PMinSS=$((PMaxSS/2))
  StartS=$(((PMaxSS+PMinSS)/2))
  sed -i 's/pm.max_children=.*/pm.max_children='$FPMS'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
  sed -i 's/pm.start_servers=.*/pm.start_servers='$StartS'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
  sed -i 's/pm.min_spare_servers=.*/pm.min_spare_servers='$PMinSS'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
  sed -i 's/pm.max_spare_servers=.*/pm.max_spare_servers='$PMaxSS'/' /${PHP_INI_DIR}/conf.d/nextcloud.ini
  sed -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = '$PMinSS'/' /usr/local/etc/php-fpm.d/www.conf
  sed -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = '$PMaxSS'/' /usr/local/etc/php-fpm.d/www.conf
  sed -i 's/memory_limit=.*/memory_limit='"$AvailableRAM"M'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
  sed -i 's/upload_max_filesize=.*/upload_max_filesize='"$AvailableRAM"M'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
  sed -i 's/post_max_size=.*/post_max_size='"$AvailableRAM"M'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
  sed -i 's/pm.max_children =.*/pm.max_children = '$FPMS'/' /usr/local/etc/php-fpm.d/www.conf
  sed -i 's/pm.start_servers =.*/pm.start_servers = '$StartS'/' /usr/local/etc/php-fpm.d/www.conf
  sed -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = '$PMinSS'/' /usr/local/etc/php-fpm.d/www.conf
  sed -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = '$PMaxSS'/' /usr/local/etc/php-fpm.d/www.conf
  export PHP_PM_MAX_CHILDREN=$FPMS
  export PHP_MEMORY_LIMIT=$AvailableRAM
  export PHP_UPLOAD_LIMIT=$AvailableRAM
  kill -USR2 $(pidof php-fpm)
) &

exec "$@"
