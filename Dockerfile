FROM nextcloud:26-fpm
    
RUN set -ex; \
    \
    apt update; \
    apt install -y --no-install-recommends \
        imagemagick \
        $(apt-cache search libmagickcore-6.q[0-9][0-9]-[0-9]-extra | cut -d " " -f1) \
        procps \
	    nano \
        wget \
        samba-client \
    ; 
   # rm -rf /var/lib/apt/lists/*;

RUN mkdir -p /opt/ffmpeg \
    && cd /opt/ffmpeg \
    && owner_repo='jellyfin/jellyfin-ffmpeg'; latest_version_url="$(curl -s https://api.github.com/repos/$owner_repo/releases/latest | grep "browser_download_url.*linux64-gpl.tar.xz" | cut -d : -f 2,3 | tr -d \")"; echo $latest_version_url; basename $latest_version_url ; wget --content-disposition $latest_version_url \
    && tar -xvf *linux64-gpl.tar.xz \
    && cd / \
    && ln -s /opt/ffmpeg/ffmpeg /usr/bin \
    && ln -s /opt/ffmpeg/ffprobe /usr/bin

RUN set -ex; \
	apt-get clean autoclean \
	&& apt-get autoremove --yes

ENV PHP_PM_MAX_CHILDREN 25

RUN { \
        echo 'memory_limit=8G'; \
        echo 'upload_max_filesize=8G'; \
        echo 'pm.max_children=25'; \
    } > "${PHP_INI_DIR}/conf.d/nextcloud.ini";

ENV NEXTCLOUD_UPDATE=1
COPY tweaks.sh /
RUN chmod a+x /*.sh
CMD ["/bin/bash", "-c", "source /tweaks.sh php-fpm"]
