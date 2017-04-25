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
  #  redis \
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
    python \
    py2-pip \
    # additional php modules
    php7-pdo_pgsql@testing \
    php7-pdo_mysql@testing \
    php7-posix@testing \
    php7-dom@testing \
    php7-ftp@testing \
    php7-exif@testing \
    php7-intl@testing \
    php7-gmp@testing \
    php7-bz2@testing \
    php7-ctype@testing \
    php7-iconv@testing \
    php7-xml@testing \
    php7-zip@testing \
    php7-xmlreader@testing \
    php7-json@testing \
    php7-xmlwriter@testing \
    php7-fileinfo@testing \
    #nextcloud packages
	nextcloud@community \
	nextcloud-texteditor@community \
	nextcloud-gallery@community \
	nextcloud-activity@community \
	nextcloud-templateeditor@community \
	nextcloud-doc@community \
	nextcloud-pdfviewer@community \
	nextcloud-notifications@community \
	nextcloud-videoplayer@community 

# install pythong pips for geolocation of gpx files for nextcloud app gpxpod
RUN pip install gpxpy geojson

# make folders
RUN mkdir -pv /etc/nginx/sites-enabled/

# Volumes
VOLUME ["/media/owncloud"]

# expose the ports needed
EXPOSE 80 443

# copy configs
COPY conf/nginx/nginx.conf /etc/nginx/
COPY conf/nginx/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf
COPY conf/php-fpm/php-fpm.conf /etc/php7/
COPY conf/owncloud/config.php /tmp/
COPY conf/autoconfig.php /tmp/

# prepare init script for start
ADD init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/init.sh"]
