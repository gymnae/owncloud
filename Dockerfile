##
#
# owncloud based on, inspired by and ripped off from:
#	1. http://wiki.alpinelinux.org/wiki/OwnCloud
#	2. https://github.com/jchaney/owncloud
#	3. https://github.com/splattael/docker-owncloud/blob/master/Makefile
#	4. https://github.com/psi-4ward/docker-owncloud/
#

FROM gymnae/webserverbase

# add the packages needed and other initial preparations
RUN apk-install \
    redis \
    freetype \    
    libmcrypt \
    libjpeg \
    libltdl \
    libpng \
    libpq \
    libxml2 \
    libbz2 \
 php-mcrypt \
    php-openssl \
    php-pgsql \
    php-pdo_pgsql \
    php-posix \
  php-dom \
    php-exif \
    php-gd \
    php-bz2 \
    php-ctype \
    php-dom \
    php-exif \
    php-iconv \
    php-json \
    php-xml \
    php-zip \
    php-zlib \
php-redis@testing \
	owncloud-mysql \
	owncloud-texteditor \
	owncloud-documents \
	owncloud-contacts \
	owncloud-calendar \
	owncloud-encryption \
	owncloud-music \
	owncloud-external \
	musl \
	owncloud-videoviewer && \
	  rm -rf /var/cache/apk/*

# make folders
#RUN mkdir -pv /opt/www/owncloud
RUN mkdir -pv /etc/nginx/sites-enabled/
## Fixes: PHP is configured to populate raw post data. Since PHP 5.6 this will lead to PHP throwing notices for perfectly valid code. #19
#RUN echo 'always_populate_raw_post_data = -1' | tee -a /etc/php/cli/php.ini /etc/php/php.ini

## Allow usage of `sudo -u www-data php /var/www/owncloud/occ` with APC.
## FIXME: Temporally: https://github.com/owncloud/core/issues/17329
#RUN echo 'apc.enable_cli = 1' >> /etc/php5/cli/php.ini

# Volumes
VOLUME ["/media/owncloud"]


# environment files at the end
# usually ignored once installled
ENV OWNCLOUDVERSION=8.2.2

# expose the ports needed
EXPOSE 80 443

# copy configs
COPY conf/nginx/nginx.conf /etc/nginx/
COPY conf/nginx/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf
COPY conf/php-fpm/php-fpm.conf /etc/php/
COPY conf/owncloud/config.php /tmp/
COPY conf/autoconfig.php /tmp/

# prepare init script for start
ADD init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/init.sh"]

