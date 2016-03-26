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
    # redis server
    redis \
    # server modules
    freetype \    
    libmcrypt \
    libjpeg \
    libltdl \
    libpng \
    libpq \
    libxml2 \
    libbz2 \
    ffmpeg \
    # additional php modules
    php-mcrypt \
    php-openssl \
    php-pgsql \
    php-pdo_pgsql \
    php-pdo_mysql \
    php-posix \
    php-dom \
    php-ftp \
    php-exif \
    php-mysql \
    php-intl \
    php-gmp \
    php-bz2 \
    php-ctype \
    php-iconv \
    php-xml \
    php-zip \
    php-zlib \
    php-xmlreader \
    php-redis@testing \
    #owncloud packages
	owncloud \
	owncloud-texteditor \
	owncloud-documents \
	owncloud-contacts \
	owncloud-calendar \
	owncloud-encryption \
	owncloud-music \
	owncloud-external \
	owncloud-gallery \
	musl \ 
	owncloud-videoplayer 

# make folders
RUN mkdir -pv /etc/nginx/sites-enabled/

# Volumes
VOLUME ["/media/owncloud"]


# environment files at the end
# usually ignored once installed
#ENV OWNCLOUDVERSION=8.2.2

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
