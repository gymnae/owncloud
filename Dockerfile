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
    php7-pdo_pgsql@community \
    php7-posix@community \
    php7-dom@community \
    php7-ftp@community \
    php7-exif@community \
    php7-intl@community \
    php7-gmp@community \
    php7-bz2@community \
    php7-ctype@community \
    php7-iconv@community \
    php7-xml@community \
    php7-zip@community \
    php7-xmlreader@community \
    php7-json@community \
    php7-xmlwriter@community \
    php7-fileinfo@community \
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
