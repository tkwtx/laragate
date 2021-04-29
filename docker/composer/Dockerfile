FROM php:7.4-fpm

WORKDIR /var/www/app

RUN apt-get update && \
	apt-get install -y \
		git \
		zip \
		unzip

RUN curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer
