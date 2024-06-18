FROM nextcloud:29-fpm 

RUN set -ex; \
    \
    apt update; \
    apt install -y --no-install-recommends \
	libfcgi-bin \
        libbz2-dev \
	checkinstall \
        $(apt-cache search libmagickcore-6.q[0-9][0-9]-[0-9]-extra | cut -d " " -f1) \
        procps \
	nano \
        wget \
	cmake \
   	git \
	yasm \
	libltdl-dev \
 	build-essential \
	python3-venv \
        samba-client \
    ; 
   # rm -rf /var/lib/apt/lists/*;
   
#RUN git clone https://aomedia.googlesource.com/aom; \
#    cd aom; \
#    mkdir build; \
#    cd build; \
#    cmake ..; \
#    make; \
 #   checkinstall; \
#    rm -rf /aom /var/www/html/aom \
#    ;
   
#RUN set -ex; \
#	\
# 	apt update; \
#  	apt install -y --no-install-recommends \
#   	libmagickwand-dev; \
#    	git clone https://github.com/Imagick/imagick.git; \
#     	cd imagick; \
#	phpize; \
# 	./configure; \
#  	make; \
#   	checkinstall; \
#	rm -rf imagick; \
#     	apt autoremove -y

## add bz2 module, even if may not be needed - https://github.com/nextcloud/server/pull/43013
RUN	docker-php-ext-install bz2

## need to fix to switch to adding repo of jellyfin for arch specific file
#RUN mkdir -p /opt/ffmpeg \
#    && cd /opt/ffmpeg \
#    && owner_repo='jellyfin/jellyfin-ffmpeg'; latest_version_url="$(curl -s https://api.github.com/repos/$owner_repo/releases/latest | grep "browser_download_url.*linux64-gpl.tar.xz" | cut -d : -f 2,3 | tr -d \")"; echo $latest_version_url; basename $latest_version_url ; wget --content-disposition $latest_version_url \
#    && tar -xvf *linux64-gpl.tar.xz \
#    && cd / \
#    && ln -s /opt/ffmpeg/ffmpeg /usr/bin \
#    && ln -s /opt/ffmpeg/ffprobe /usr/bin
#	/bin/bash -c "source /add_jellyfin_repo.sh"
# No need for updating because the shell script above does that for us.
# RUN apt update

RUN set -ex; \
    \
    apt update; \
    apt install -y extrepo --no-install-recommends; \
    extrepo enable jellyfin

RUN set -ex; \
    \
    apt update; \
    apt install -y jellyfin-ffmpeg6 --no-install-recommends \
    && ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/bin \
    && ln -s /usr/lib/jellyfin-ffmpeg/ffprobe /usr/bin

RUN  t=$(mktemp) && \
        wget 'https://dist.1-2.dev/imei.sh' -qO "$t" && \
        bash "$t" --use-checkinstall --force  && \
        rm "$t"

RUN sed -i "s/Components: main/Components: main non-free non-free-firmware/" /etc/apt/sources.list.d/debian.sources
## moved to tweaks, because only possible for amd64 and not arm
# RUN apt update && \
#    apt install -y intel-media-va-driver-non-free

RUN set -ex; \
	apt clean autoclean; \
	apt update; \
	apt --fix-broken install -y; \
	apt remove -y \
		git \
		cmake \
		extrepo \
		build-essential \
		libfcgi-bin \
		libbz2-dev \
		libltdl-dev \
		libde265-dev libx265-dev libltdl-dev libopenjp2-7-dev liblcms2-dev libbrotli-dev libzip-dev libbz2-dev \
		liblqr-1-0-dev libzstd-dev libgif-dev libjpeg-dev libopenexr-dev libpng-dev libwebp-dev \
		librsvg2-dev libwmf-dev libxml2-dev libtiff-dev libraw-dev ghostscript \
		libpango1.0-dev libdjvulibre-dev libfftw3-dev libgs-dev libgraphviz-dev \
		libmagickwand-dev; \
	apt autoremove --yes

RUN set -ex; \
        apt clean autoclean

COPY *.sh /
RUN chmod a+x /*.sh 

ENV NEXTCLOUD_UPDATE=1
#HEALTHCHECK --interval=60s --timeout=10s --start-period=20s  \
#  CMD SCRIPT_NAME=/var/www/html/status.php SCRIPT_FILENAME=/var/www/html/status.php \
#  REQUEST_METHOD=GET /usr/bin/cgi-fcgi -connect /var/run/php-fpm/php-fpm.sock / | \
#  grep '\"installed\":true' | grep '\"maintenance\":false' | grep '\"needsDbUpgrade\":false' || exit 1
#CMD ["/bin/bash", "-c", "source /tweaks.sh php-fpm"]
#COPY *.sh upgrade.exclude /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/tweaks.sh php-fpm"]
