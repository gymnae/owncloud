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

RUN	echo @nc http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
#	&& echo @community http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
#	&& echo http://dl-cdn.alpinelinux.org/alpine/latest-stable/main | tee -a /etc/apk/repositories2 \
#	&& echo http://dl-cdn.alpinelinux.org/alpine/latest-stable/community | tee -a /etc/apk/repositories2 \
RUN apk --no-cache add \ 
    # redis servery
    #  redis \
    # server modules
    freetype \    
    libmcrypt \
    icu-libs \
    libjpeg \
    libltdl \
    libpng \
    libpq \
    libxml2 \
    librsvg \
    imagemagick6 \
    imagemagick6-libs \
    libbz2 \
    ffmpeg \
    musl \ 
    python3 \ 
    python3-dev \
    py3-pip \
#    build-base \
# additional php modules
	nginx \
	nginx-mod-http-redis2 \
	nginx-mod-http-upload-progress \
	nginx-mod-http-geoip \
	nginx-mod-http-cache-purge \
	nginx-mod-http-fancyindex \
	nginx-mod-rtmp \
	php7-openssl \
	#php7-cli@testing \
	php7-curl \
        php7 \
	php7-fpm \
	php7-gd \
	php7-redis \
	libmaxminddb \
        php7-pdo_mysql \
        php7-pgsql \
        php7-sqlite3 \      
    php7-pdo_pgsql \
    php7-posix \
    php7-dom \
    php7-ftp \
    php7-exif \
    php7-intl \
    php7-gmp \
    php7-bz2 \
    php7-ctype \
    php7-iconv \
    php7-xml \
    php7-fileinfo \
    php7-zip \
    php7-xmlreader \
    php7-json \
    php7-xmlwriter \
    php7-fileinfo \
    php7-opcache \
    php7-apcu \
    nginx-mod-http-headers-more \
    php7-pecl-imagick \
    #nextcloud packages
	nextcloud@nc \
	nextcloud-doc@nc \
	#nextcloud-dav \
	#nextcloud-files \
	nextcloud-accessibility@nc \
	nextcloud-support@nc \ 
	#nextcloud-provisioning_api \
	nextcloud-federation@nc \
	nextcloud-text@nc \
	nextcloud-cloud_federation_api@nc \
	nextcloud-photos@nc \
	nextcloud-activity@nc \
	#nextcloud-twofactor_backupcodes \
	nextcloud-dashboard@nc \
	nextcloud-default-apps@nc \
        #nextcloud-settings \
	nextcloud-recommendations@nc \
        #nextcloud-oauth2 \
	nextcloud-admin_audit@nc \
	nextcloud-files_trashbin@nc \
	nextcloud-files_rightclick@nc \
	nextcloud-weather_status@nc \
        #nextcloud-files_sharing \
        #nextcloud-twofactor_backupcodes \
	nextcloud-files_versions@nc \
	nextcloud-files_external@nc \
	#nextcloud-workflowengine \
	nextcloud-theming@nc \
	nextcloud-files_pdfviewer@nc \
	nextcloud-notifications@nc \
	nextcloud-encryption@nc \
	nextcloud-logreader@nc \
	nextcloud-files_videoplayer@nc \
	nextcloud-comments@nc \
	nextcloud-federation@nc \
	nextcloud-firstrunwizard@nc \
	#nextcloud-lookup_server_connector \
	nextcloud-nextcloud_announcements@nc \
	nextcloud-password_policy@nc \
	nextcloud-serverinfo@nc \
	nextcloud-sharebymail@nc \
	nextcloud-survey_client@nc \
	nextcloud-systemtags@nc \
	nextcloud-files_sharing@nc \
        nextcloud-viewer@nc \
        nextcloud-sharebymail@nc \
        nextcloud-privacy@nc 
# install pythong pips for geolocation of gpx files for nextcloud app gpxpod
RUN pip3 install wheel  \
	&& pip3 install gpxpy geojson

# make folders
RUN mkdir -pv /etc/nginx/sites-enabled/

# Volumes
VOLUME ["/media/owncloud"]

# expose the ports needed
EXPOSE 80 443

# copy configs
COPY conf/nginx/nginx.conf /etc/nginx/
COPY conf/nginx/php_optimization.conf /etc/nginx/
COPY conf/nginx/header.conf /etc/nginx/
COPY conf/nginx/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf
COPY conf/php-fpm/php-fpm.conf /etc/php7/
COPY conf/owncloud/config.php /tmp/
COPY conf/autoconfig.php /tmp/

# prepare init script for start
ADD init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/init.sh"] 
