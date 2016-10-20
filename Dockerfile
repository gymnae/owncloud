##
#
# EXPERIMENTAL branch of nextcloud based on owncloud docker file
#
# nextcloud based on, inspired by and ripped off from:
#	1. http://wiki.alpinelinux.org/wiki/OwnCloud
#	2. https://github.com/jchaney/owncloud
#	3. https://github.com/splattael/docker-owncloud/blob/master/Makefile
#	4. https://github.com/psi-4ward/docker-owncloud/
#

FROM gymnae/webserverbase:latest

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
    musl \ 
    # additional php modules
    php5-pdo_pgsql \
    php5-pdo_mysql \
    php5-posix \
    php5-dom \
    php5-ftp \
    php5-exif \
    php5-intl \
    php5-gmp \
    php5-bz2 \
    php5-ctype \
    php5-iconv \
    php5-xml \
    php5-zip \
    php5-xmlreader \
    #nextcloud packages
	nextcloud \
	nextcloud-texteditor \
	owncloud-documents \
	owncloud-contacts \
	owncloud-calendar \
	# owncloud-encryption \
	owncloud-music \
	nextcloud-gallery \
	nextcloud-activity \
	nextcloud-templateeditor \
	nextcloud-doc \
	nextcloud-pdfviewer \
	nextcloud-videoplayer 

# make folders
RUN mkdir -pv /etc/nginx/sites-enabled/

# Volumes
VOLUME ["/media/owncloud"]

# expose the ports needed
EXPOSE 80 443

# copy configs
COPY conf/nginx/nginx.conf /etc/nginx/
COPY conf/nginx/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf
COPY conf/php-fpm/php-fpm.conf /etc/php5/
COPY conf/owncloud/config.php /tmp/
COPY conf/autoconfig.php /tmp/

# prepare init script for start
ADD init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/init.sh"]
