# Use Alpine Linux
FROM php:7.2.2-fpm-alpine

# Set Timezone Environments
ENV TIMEZONE            Asia/Shanghai
RUN \
	apk add --update tzdata && \
	cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo "${TIMEZONE}" > /etc/timezone && \
	apk del tzdata

# Install Software
RUN apk add --no-cache --virtual .build-deps \
        bash \
        openssh \
        curl \
        libjpeg-turbo-dev \
        libwebp-dev \
        libpng-dev \
        libxml2-dev \
        freetype-dev \
        libmcrypt \
        autoconf \
        g++ \
        make \
        freetds-dev \
        libxslt-dev

# In order to keep the images smaller, PHP's source is kept in a compressed tar file. To facilitate linking of PHP's source with any extension, we also provide the helper script docker-php-source to easily extract the tar or delete the extracted source. Note: if you do use docker-php-source to extract the source, be sure to delete it in the same layer of the docker image.
RUN docker-php-source extract

# Install PHP Core Extensions
RUN docker-php-ext-configure pdo
RUN docker-php-ext-configure pdo_mysql
RUN docker-php-ext-configure mysqli
RUN docker-php-ext-configure opcache
RUN docker-php-ext-configure exif
RUN docker-php-ext-configure sockets
RUN docker-php-ext-configure soap
RUN docker-php-ext-configure bcmath
RUN docker-php-ext-configure pcntl
RUN docker-php-ext-configure sysvsem
RUN docker-php-ext-configure tokenizer
RUN docker-php-ext-configure zip
RUN docker-php-ext-configure xsl
RUN docker-php-ext-configure shmop
RUN docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/include \
    --with-png-dir=/usr/include \
    --with-webp-dir=/usr/include \
    --with-freetype-dir=/usr/include




# Install PECL extensions
# Some extensions are not provided with the PHP source, but are instead available through PECL.
RUN \
    apk add --no-cache --virtual .mongodb-ext-build-deps openssl-dev && \
    pecl install redis && \
    pecl install xdebug && \
    pecl install mongodb && \
    pecl clear-cache && \
    apk del .mongodb-ext-build-deps && \
	docker-php-ext-enable redis && \
	docker-php-ext-enable xdebug && \
	docker-php-ext-enable mongodb

# Install PHP Extension
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install opcache
RUN docker-php-ext-install exif
RUN docker-php-ext-install sockets
RUN docker-php-ext-install soap
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install sysvsem
RUN docker-php-ext-install tokenizer
RUN docker-php-ext-install zip
RUN docker-php-ext-install xsl
RUN docker-php-ext-install shmop
RUN docker-php-ext-install gd


# Delete PHP Source
RUN docker-php-source delete

# Uninstall some dev to keep smaller
#RUN apk del .build-deps
RUN apk del g++ make autoconf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install phpunit, the tool that we will use for testing
RUN curl --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar
RUN chmod +x /usr/local/bin/phpunit

# Expose ports
EXPOSE 9000

# Entry point
CMD ["php-fpm"]

