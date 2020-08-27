FROM alpine:3.11

LABEL description "Lightweight standalone Adminer container based on Alpine Linux."

# developed by Florian Kleber for terms of use have a look at the LICENSE file
MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# Adminer change here to desired version
ARG ADMINER_VERSION=4.7.7
ARG ADMINER_SHA256=8b05028901fc7dc486cefcf660c103ceb27f588fcbde2952d31264584a4384ab

# Theme change here to desired version
ARG ADMINER_THEME=pepa-linha

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@main http://dl-cdn.alpinelinux.org/alpine/v3.11/main/" >> /etc/apk/main && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/v3.11/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/v3.11/community/" >> /etc/apk/repositories && \
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
    && ADMINER_FILE="adminer-${ADMINER_VERSION}-en.php" \
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

# deploy init script
ADD docker-entrypoint.sh /

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

# change to none root user
USER adminer

CMD	[ "php", "-S", "[::]:8888", "-t", "/var/www/html" ]

# SPDX-License-Identifier: (EUPL-1.2)
# Copyright © 2019-2020 Simon Prast
