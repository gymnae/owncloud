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

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
RUN apk --no-cache add \ 
    # redis server
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
    build-base \
# additional php modules
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
	nextcloud \
	nextcloud-doc \
	#nextcloud-dav \
	#nextcloud-files \
	nextcloud-accessibility \
	nextcloud-support \ 
	#nextcloud-provisioning_api \
	nextcloud-federation \
	nextcloud-text \
	nextcloud-cloud_federation_api \
	nextcloud-photos \
	nextcloud-activity \
	#nextcloud-twofactor_backupcodes \
	#nextcloud-default-apps \
	#nextcloud-oauth2 \
	nextcloud-admin_audit \
	nextcloud-files_trashbin \
	nextcloud-files_rightclick \
        #nextcloud-files_sharing \
        #nextcloud-twofactor_backupcodes \
	nextcloud-files_versions \
	nextcloud-files_external \
	#nextcloud-workflowengine \
	nextcloud-theming \
	nextcloud-files_pdfviewer \
	nextcloud-notifications \
	nextcloud-encryption \
	nextcloud-logreader \
	nextcloud-files_videoplayer \
	nextcloud-comments \
	nextcloud-federation \
	nextcloud-firstrunwizard \
	#nextcloud-lookup_server_connector \
	nextcloud-nextcloud_announcements \
	nextcloud-password_policy \
	nextcloud-serverinfo \
	nextcloud-sharebymail \
	nextcloud-survey_client \
	nextcloud-systemtags \
	nextcloud-files_sharing \
        nextcloud-viewer \
        nextcloud-sharebymail \
        nextcloud-privacy 
# install pythong pips for geolocation of gpx files for nextcloud app gpxpod
RUN pip3 install gpxpy geojson

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
