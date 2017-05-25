# Use Alpine Linux
FROM php:7.1.5-fpm-alpine

# Maintainer
MAINTAINER Connor <connor.niu@gmail.com>

# Set Timezone Environments
ENV TIMEZONE            Asia/Shanghai
RUN \
	apk add --update tzdata && \
	cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo "${TIMEZONE}" > /etc/timezone && \
	apk del tzdata

# Install Software
RUN apk add --no-cache --virtual .ext-deps \
        bash \
        curl \
        git \
        nodejs \
        libjpeg-turbo-dev \
        libwebp-dev \
        libpng-dev \
        libxml2-dev \
        freetype \
        freetype-dev \
        libmcrypt \
        autoconf \
        supervisor

RUN docker-php-ext-configure pdo
RUN docker-php-ext-configure pdo_mysql
RUN docker-php-ext-configure opcache
RUN docker-php-ext-configure exif
RUN docker-php-ext-configure sockets
RUN docker-php-ext-configure soap
RUN docker-php-ext-configure bcmath
RUN docker-php-ext-configure pcntl
RUN docker-php-ext-configure sysvsem
RUN docker-php-ext-configure tokenizer
RUN docker-php-ext-configure zip
RUN docker-php-ext-configure shmop
RUN docker-php-ext-configure xmlrpc
RUN docker-php-ext-configure mysqli
RUN docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/include --with-png-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include

# Install and Enable Redis Xdebug Mongodb
RUN \
    apk add --no-cache --virtual .mongodb-ext-build-deps openssl-dev && \
    pecl install redis && \
    pecl install xdebug && \
    pecl install mongodb && \
    pecl clear-cache && \
    apk del .mongodb-ext-build-deps && \
	docker-php-ext-enable redis.so && \
	docker-php-ext-enable xdebug.so && \
	docker-php-ext-enable mongodb.so

# Install PHP extention
RUN docker-php-ext-install gd
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install opcache
RUN docker-php-ext-install exif
RUN docker-php-ext-install sockets
RUN docker-php-ext-install soap
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install sysvsem
RUN docker-php-ext-install tokenizer
RUN docker-php-ext-install zip
RUN docker-php-ext-install shmop
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install mysqli

# Delete PHP Source
RUN docker-php-source delete

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install phpunit, the tool that we will use for testing
RUN curl --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar
RUN chmod +x /usr/local/bin/phpunit

# Install APIDoc
RUN npm install apidoc -g --registry=https://registry.npm.taobao.org

# Install APIDoc for Grunt
RUN npm install grunt-apidoc --save-dev --registry=https://registry.npm.taobao.org

# Copy php.ini
COPY php.ini /usr/local/etc/php

# Copy supervisor
RUN mkdir -p /etc/supervisor

COPY supervisor.conf /etc/supervisor

# Work Directory
WORKDIR /var/www/html

COPY start.sh /usr/local/bin

ENTRYPOINT ["/usr/local/bin/start.sh"]

# Expose ports
EXPOSE 9000

# Entry point
CMD ["php-fpm"]
