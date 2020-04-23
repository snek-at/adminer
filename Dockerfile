FROM alpine:latest

LABEL description "Lightweight standalone Adminer container based on Alpine Linux."

# developed by Florian Kleber for terms of use have a look at the LICENSE file
MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# Adminer change here to desired version
ARG ADMINER_VERSION=4.6.3
ARG ADMINER_SHA256=aa4a60ae2d1d0401cf26282451db8e57a1a66622e8048cdb3fd3a6db1f0f24e2

# Theme change here to desired version
ARG ADMINER_THEME=pepa-linha

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@main http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/main && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
        bash@main \
        php7@community \
        php7-session@community \
        php7-pdo_mysql@community \
        php7-pdo_pgsql@community \
        php7-pdo_sqlite@community \
        tini@community \
    \
    && echo "## Setup permissions ##" \
    && addgroup -S adminer ${VERSION} \
    && adduser -S -G adminer adminer \
    && mkdir -p /var/www/html \
    && mkdir -p /var/www/html/plugins-enabled \
    \
    && echo "## Download and install adminer and alternative design ##" \
    && ADMINER_FILE="adminer-${ADMINER_VERSION}.php" \
    && wget "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/${ADMINER_FILE}" \
    && wget -q "https://raw.githubusercontent.com/vrana/adminer/master/designs/${ADMINER_THEME}/adminer.css" -P /var/www/html \
    && echo "Verifying integrity of ${ADMINER_FILE}..." \
    && echo "$ADMINER_SHA256 *${ADMINER_FILE}" | sha256sum -c - \
    && echo "All seems good, hash is valid." \
    && mv ${ADMINER_FILE} /var/www/html/index.php \
    && chown -R adminer:adminer /var/www/html /etc/php7 \
    \
    && rm -rf /tmp/* /var/cache/apk/* /var/cache/distfiles/*

EXPOSE 8888

# add license
ADD LICENSE /

# deploy init script
ADD docker-entrypoint.sh /

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

# change to none root user
USER adminer

CMD	[ "php", "-S", "[::]:8888", "-t", "/var/www/html" ]
