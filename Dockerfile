FROM nextcloud:25-fpm-alpine

RUN set -ex; \
    \
    apk add --no-cache \
        ffmpeg \
        imagemagick \
        procps \
        samba-client \
        supervisor \
#       libreoffice \
    ;

ENV PHP_PM_MAX_CHILDREN 16

RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        imap-dev \
        krb5-dev \
        openssl-dev \
        samba-dev \
        bzip2-dev \
    ; \
    \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-install \
        bz2 \
        imap \
    ; \
    pecl install smbclient; \
    docker-php-ext-enable smbclient; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .nextcloud-phpext-rundeps $runDeps; \
    apk del .build-deps

RUN mkdir -p \
    /var/log/supervisord \
    /var/run/supervisord \
;
RUN { \
        echo 'memory_limit=8G'; \
        echo 'upload_max_filesize=8G'; \
        echo 'pm.max_children=25'; \
    } > "${PHP_INI_DIR}/conf.d/nextcloud.ini";
    
RUN sed -i "s/pm.max_children = .*/pm.max_children = 100/" /usr/local/etc/php-fpm.d/www.conf
    
COPY supervisord.conf /

ENV NEXTCLOUD_UPDATE=1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
