FROM php:8.2-cli

# Dependencias del sistema y extensiones necesarias
RUN apt-get update && apt-get install -y \
    git unzip pkg-config ca-certificates \
    libzip-dev libpng-dev libxml2-dev \
    sqlite3 libsqlite3-dev \
 && docker-php-ext-install pdo pdo_mysql pdo_sqlite zip

# Composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Variables para Composer en contenedor
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

WORKDIR /app

# Copiamos todo el proyecto primero (simple y compatible con scripts de Laravel)
COPY . .

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist -vvv

# Genera .env y APP_KEY y crea la BD SQLite vacía
RUN php -r "file_exists('.env') || copy('.env.example', '.env');" \
 && php artisan key:generate --force \
 && mkdir -p database && touch database/database.sqlite

ENV PORT=8080
EXPOSE 8080

CMD php artisan serve --host 0.0.0.0 --port $PORT
