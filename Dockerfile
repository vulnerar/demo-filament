FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
    software-properties-common \
    unzip \
    curl \
    gpg-agent \
    gnupg \
    ca-certificates

RUN apt-get update && apt-get install --no-install-recommends -y \
	supervisor \
	nginx \
	php-cli \
	php-fpm \
	php-curl \
	php-bcmath \
	php-sqlite3 \
	php-mbstring \
	php-dom \
    php-gd \
	php-zip \
	php-intl \
	php-tokenizer \
	php-xml \
    php-soap \
	dnsutils \
	vim \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/

ARG UID=33
ARG GID=33

RUN groupmod --gid $GID www-data \
    && usermod --gid $GID --uid $UID www-data

RUN mkdir -p \
	/var/run/supervisor \
	/run/nginx \
	/run/php \
	/var/log/php \
	&& chown -R www-data:www-data \
	/var/run/supervisor \
	/run/nginx \
	/run/php \
	/var/www \
	/var/log/supervisor \
	/var/log/nginx \
	/var/log/php

COPY --from=composer:2.9 /usr/bin/composer /usr/bin/composer

COPY --chown=www-data:www-data . /var/www/
RUN cp ./docker/files/supervisor/supervisord.conf /etc/supervisor/supervisord.conf && \
	cp ./docker/files/nginx/nginx.conf /etc/nginx/nginx.conf && \
	cp ./docker/files/php/php-fpm.conf /etc/php/8.5/fpm/php-fpm.conf

USER www-data:www-data

RUN composer install --optimize-autoloader

USER root:root
RUN curl -o- https://fnm.vercel.app/install | bash
RUN ~/.local/share/fnm/fnm install 24

RUN . ~/.bashrc && npm install && npm run build

USER www-data:www-data

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
