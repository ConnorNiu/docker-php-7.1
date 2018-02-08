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
         curl \
         g++ \
         make \
         autoconf \
    && apk add --no-cache \
         bash \
         openssh \
         libssl1.0 \
         libxslt-dev \
         libjpeg-turbo-dev \
         libwebp-dev \
         libpng-dev \
         libxml2-dev \
         freetype-dev \
         libmcrypt \
         freetds-dev

# In order to keep the images smaller, PHP's source is kept in a compressed tar file. To facilitate linking of PHP's source with any extension, we also provide the helper script docker-php-source to easily extract the tar or delete the extracted source. Note: if you do use docker-php-source to extract the source, be sure to delete it in the same layer of the docker image.
RUN docker-php-source extract

# Install PHP Core Extensions
RUN docker-php-ext-configure pdo \
                             pdo_mysql \
                             mysqli \
                             opcache \
                             exif \
                             sockets \
                             soap \
                             bcmath \
                             pcntl \
                             sysvsem \
                             tokenizer \
                             zip \
                             xsl \
                             shmop \
                             gd \
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
RUN docker-php-ext-install pdo \
                           pdo_mysql \
                           mysqli \
                           opcache \
                           exif \
                           sockets \
                           soap \
                           bcmath \
                           pcntl \
                           sysvsem \
                           tokenizer \
                           zip \
                           xsl \
                           shmop \
                           gd


# Delete PHP Source
RUN docker-php-source delete

# Uninstall some dev to keep smaller
RUN apk del .build-deps

# Output Log
RUN  ln -sf /dev/stdout /usr/local/var/log/php-fpm.access.log \
        && ln -sf /dev/stderr /usr/local/var/log/php-fpm.error.log

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install phpunit, the tool that we will use for testing
RUN curl --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar
RUN chmod +x /usr/local/bin/phpunit

# Expose ports
EXPOSE 9000

# Entry point
CMD ["php-fpm"]
