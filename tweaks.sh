#!/bin/bash

# start php-fpm in the background to be able to determine "optimal" settings

php-fpm &
sleep 2

# make the following commands not fail the script if they fail
set +e

# calculate following https://www.c-rieger.de/nextcloud-installationsanleitung-apache2/#Installation%20PHP%208.0 howto
AvailableRAM=$(awk '/MemAvailable/ {printf "%d", $2/1024}' /proc/meminfo)
AverageFPM=$(ps --no-headers -o 'rss,cmd' -C php-fpm | awk '{ sum+=$1 } END { printf ("%d\n", sum/NR/1024,"M") }')
FPMS=$((AvailableRAM/AverageFPM))
PMaxSS=$((FPMS*2/3))
PMinSS=$((PMaxSS/2))
StartS=$(((PMaxSS+PMinSS)/2))

# sed results into two locations, because i don't know which one stick
sed -i 's/pm.max_children=.*/pm.max_children='$FPMS'/' ${PHP_INI_DIR}/conf.d/nextcloud.ini
echo 'pm.start_servers='"$StartS" >> ${PHP_INI_DIR}/conf.d/nextcloud.ini
echo 'pm.min_spare_servers='"$PMinSS" >> ${PHP_INI_DIR}/conf.d/nextcloud.ini
echo 'pm.max_spare_servers='"$PMaxSS" >> ${PHP_INI_DIR}/conf.d/nextcloud.ini

sed -i 's/pm.max_children =.*/pm.max_children = '$FPMS'/' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/pm.start_servers =.*/pm.start_servers = '$StartS'/' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = '$PMinSS'/' /usr/local/etc/php-fpm.d/www.conf
sed -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = '$PMaxSS'/' /usr/local/etc/php-fpm.d/www.conf

pkill php-fpm

# add hacks to enable preview generation and proper cron jobs even if encryption is enabled
sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/custom_apps/previewgenerator/lib/Command/PreGenerate.php
sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/custom_apps/previewgenerator/lib/Command/Generate.php
sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/custom_apps/memories/lib/Command/Index.php
sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/apps/previewgenerator/lib/Command/PreGenerate.php
sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/apps/previewgenerator/lib/Command/Generate.php
sed -i '\|this->encryptionManager->isEnabled|,/}/ s/^#*/#/' /var/www/html/apps/memories/lib/Command/Index.php


exec "$@"