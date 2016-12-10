FROM php:7.1.0-fpm-alpine

# Maintainer
MAINTAINER Connor <connor.niu@gmail.com>

RUN apk add --no-cache --virtual .ext-deps \
        bash \
        curl \
        libjpeg-turbo-dev \
        libwebp-dev \
        libpng-dev \
        freetype-dev
RUN \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure sockets && \
    docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/include --with-png-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include


RUN \
    apk add --no-cache --virtual .mongodb-ext-build-deps openssl-dev && \
    pecl install redis && \
    pecl install mongodb && \
    pecl clear-cache && \
    apk del .mongodb-ext-build-deps

RUN \
    docker-php-ext-install pdo_mysql opcache exif gd sockets soap && \
    docker-php-ext-enable redis.so && \
    docker-php-ext-enable mongodb.so && \
    docker-php-source delete

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

EXPOSE 9000
CMD ["php-fpm"]