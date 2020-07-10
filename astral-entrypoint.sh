#!/usr/bin/env sh
set -e

php artisan migrate

/usr/bin/caddy --conf /etc/Caddyfile --log stdout
