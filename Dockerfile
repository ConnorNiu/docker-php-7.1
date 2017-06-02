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
        supervisor \
        g++ \
        make \
        unixodbc-dev \
        freetds \
        freetds-dev \
        unixodbc

RUN docker-php-source extract

# Install PHP extention
RUN docker-php-ext-configure pdo
RUN docker-php-ext-configure pdo_mysql
RUN docker-php-ext-configure pdo_dblib
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
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-png-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include

RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo_dblib
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
RUN docker-php-ext-install gd


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


# Install ODBC
RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr
RUN docker-php-ext-install pdo_odbc
COPY odbc/*.ini /etc/

RUN ln -s /usr/include /usr/local/incl

RUN set -ex; \
	docker-php-source extract; \
	{ \
		echo '# https://github.com/docker-library/php/issues/103#issuecomment-271413933'; \
		echo 'AC_DEFUN([PHP_ALWAYS_SHARED],[])dnl'; \
		echo; \
		cat /usr/src/php/ext/odbc/config.m4; \
	} > temp.m4; \
	mv temp.m4 /usr/src/php/ext/odbc/config.m4; \
	apk add --no-cache unixodbc-dev; \
	docker-php-ext-configure odbc --with-unixODBC=shared,/usr; \
	docker-php-ext-install odbc; \
	docker-php-source delete


# Delete PHP Source
RUN docker-php-source delete

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install phpunit, the tool that we will use for testing
RUN curl --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar
RUN chmod +x /usr/local/bin/phpunit

# Install APIDoc
RUN npm install -g apidoc

# Install Grunt
RUN npm install -g grunt-cli

# Install APIDoc for Grunt
RUN npm install grunt-apidoc --save-dev

# Copy php.ini
COPY php.ini /usr/local/etc/php

# Work Directory
WORKDIR /var/www/html

# supervisor
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisor/supervisor.conf /etc/supervisor
COPY supervisor/conf.d/laravel-worker.conf /etc/supervisor/conf.d

# Expose ports
EXPOSE 9000

# Entry point
CMD ["php-fpm"]
#CMD ["supervisord -c /etc/supervisor/supervisor.conf"]
