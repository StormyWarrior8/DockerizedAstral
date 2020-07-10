FROM composer:latest as c

RUN git clone https://github.com/astralapp/astral.git
WORKDIR astral
RUN composer install

FROM node:lts as a

COPY --from=c /app/astral/ /astral/

WORKDIR /astral
RUN yarn
RUN yarn dev
RUN rm -rf node_modules/

FROM php:7.4-fpm

COPY --from=a --chown=www-data:www-data /astral/ ./

COPY .env /var/www/html/.env
RUN php artisan key:generate
RUN docker-php-ext-install mysqli pdo pdo_mysql


# Install application dependencies
RUN curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "https://caddyserver.com/download/linux/amd64?plugins=http.expires,http.realip&license=personal" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && chmod 0755 /usr/bin/caddy \
    && /usr/bin/caddy -version 

COPY Caddyfile /etc/Caddyfile

COPY astral-entrypoint.sh /usr/local/bin/astral-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/astral-entrypoint.sh"]
