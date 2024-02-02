FROM nextcloud:28-fpm 
 
RUN set -ex; \
    \
    apt update; \
    apt install -y --no-install-recommends \
        imagemagick \
	libfcgi-bin \
        $(apt-cache search libmagickcore-6.q[0-9][0-9]-[0-9]-extra | cut -d " " -f1) \
        procps \
	nano \
        wget \
	php-bz2 \
 	php-intl \
	python3-venv \
        samba-client \
    ; 
   # rm -rf /var/lib/apt/lists/*;

## need to fix to switch to adding repo of jellyfin for arch specific file
#RUN mkdir -p /opt/ffmpeg \
#    && cd /opt/ffmpeg \
#    && owner_repo='jellyfin/jellyfin-ffmpeg'; latest_version_url="$(curl -s https://api.github.com/repos/$owner_repo/releases/latest | grep "browser_download_url.*linux64-gpl.tar.xz" | cut -d : -f 2,3 | tr -d \")"; echo $latest_version_url; basename $latest_version_url ; wget --content-disposition $latest_version_url \
#    && tar -xvf *linux64-gpl.tar.xz \
#    && cd / \
#    && ln -s /opt/ffmpeg/ffmpeg /usr/bin \
#    && ln -s /opt/ffmpeg/ffprobe /usr/bin
COPY *.sh /
RUN chmod a+x /*.sh && \
	/bin/bash -c "source /add_jellyfin_repo.sh"
# No need for updating because the shell script above does that for us.
# RUN apt update

RUN apt install -y jellyfin-ffmpeg6 \
    && ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/bin \
    && ln -s /usr/lib/jellyfin-ffmpeg/ffprobe /usr/bin

RUN sed -i "s/Components: main/Components: main non-free non-free-firmware/" /etc/apt/sources.list.d/debian.sources
## moved to tweaks, because only possible for amd64 and not arm
# RUN apt update && \
#    apt install -y intel-media-va-driver-non-free

RUN set -ex; \
	apt-get clean autoclean \
	&& apt-get autoremove --yes

ENV NEXTCLOUD_UPDATE=1
#HEALTHCHECK --interval=60s --timeout=10s --start-period=20s  \
#  CMD SCRIPT_NAME=/var/www/html/status.php SCRIPT_FILENAME=/var/www/html/status.php \
#  REQUEST_METHOD=GET /usr/bin/cgi-fcgi -connect /var/run/php-fpm/php-fpm.sock / | \
#  grep '\"installed\":true' | grep '\"maintenance\":false' | grep '\"needsDbUpgrade\":false' || exit 1
#CMD ["/bin/bash", "-c", "source /tweaks.sh php-fpm"]
#COPY *.sh upgrade.exclude /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/tweaks.sh php-fpm"]
