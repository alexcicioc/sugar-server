FROM php:7.1-apache

RUN apt-get update \
    && apt-get install -y \
    graphviz \
    libmcrypt-dev \
    libpng-dev \
    libgmp-dev \
    libzip-dev \
    libc-client-dev \
    libkrb5-dev \
    libldap2-dev \
    --no-install-recommends

ADD ./config/apache2 /etc/apache2
ADD ./scripts/start-server /usr/local/bin

RUN echo 'date.timezone = GMT' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'error_log = /var/log/apache2/error.log' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'log_errors = On' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'display_errors = Off' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'post_max_size = 100M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'upload_max_filesize = 100M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'max_execution_time = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'max_input_time = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'realpath_cache_size = 512k' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'realpath_cache_ttl = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'mbstring.func_overload = 0' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.use_cookies = 1' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.cookie_httponly = 1' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.use_trans_sid = 0' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.save_handler = redis' >> /usr/local/etc/php/conf.d/docker.ini

RUN set -ex \
    && . "/etc/apache2/envvars" \
    && ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log" \
    && a2enmod headers expires deflate rewrite \
    && sed -i "s#Timeout .*#Timeout 600#" /etc/apache2/apache2.conf \
    && a2dissite 000-default \
    && a2ensite sugar

RUN docker-php-ext-install mysqli \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install gd \
    && docker-php-ext-install gmp \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-install zip \
    && docker-php-ext-install ldap \
    && pecl install xdebug \
    && pecl install redis \
    && docker-php-ext-enable redis

CMD ["start-server"]
