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

RUN 	echo rm /etc/apk/repositories
RUN	echo @nc http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories2 \ 
#	&& echo @community http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
	&& echo http://dl-cdn.alpinelinux.org/alpine/latest-stable/main | tee -a /etc/apk/repositories2 \
	&& echo http://dl-cdn.alpinelinux.org/alpine/latest-stable/community | tee -a /etc/apk/repositories2 \
	&& echo @php http://dl-cdn.alpinelinux.org/alpine/latest-stable/community | tee -a /etc/apk/repositories2
RUN apk --no-cache --repositories-file /etc/apk/repositories2 add \ 
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
	php7-openssl@php \
	#php7-cli@testing \
	php7-curl@php \
        php7@php \
	php7-fpm@php \
	php7-gd@php \
	php7-redis@php \
	libmaxminddb \
        php7-pdo_mysql@php \
        php7-pgsql@php \
        php7-sqlite3@php \      
    php7-pdo_pgsql@php \
    php7-posix@php \
    php7-dom@php \
    php7-ftp@php \
    php7-exif@php \
    php7-intl@php \
    php7-gmp@php \
    php7-bz2@php \
    php7-ctype@php \
    php7-iconv@php \
    php7-xml@php \
    php7-fileinfo@php \
    php7-zip@php \
    php7-xmlreader@php \
    php7-json@php \
    php7-xmlwriter@php \
    php7-fileinfo@php \
    php7-opcache@php \
    php7-apcu@php \
    nginx-mod-http-headers-more@nc \
    php7-pecl-imagick@php \
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
	#nextcloud-default-apps \
        #nextcloud-settings \
	nextcloud-recommendations@nc \
        #nextcloud-oauth2 \
	nextcloud-admin_audit@nc \
	nextcloud-files_trashbin@nc \
	nextcloud-files_rightclick@nc \
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
