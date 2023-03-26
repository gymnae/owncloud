FROM nextcloud:26-fpm
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        imagemagick \
        $(apt-cache search libmagickcore-6.q[0-9][0-9]-[0-9]-extra | cut -d " " -f1) \
        procps \
	nano \
        samba-client \
    ; \
    rm -rf /var/lib/apt/lists/*;

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
