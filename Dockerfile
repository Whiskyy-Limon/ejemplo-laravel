FROM php:8.2-cli

# Dependencias del sistema y extensiones necesarias
RUN apt-get update && apt-get install -y \
    git unzip pkg-config libzip-dev libpng-dev libxml2-dev \
    sqlite3 libsqlite3-dev \
 && docker-php-ext-install pdo pdo_mysql pdo_sqlite zip

# Composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Instala dependencias por lock (aprovecha la cache de capas)
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copia el resto del código
COPY . .

# Genera .env y APP_KEY y crea la BD SQLite vacía
RUN php -r "file_exists('.env') || copy('.env.example', '.env');" \
 && php artisan key:generate --force \
 && mkdir -p database && touch database/database.sqlite

# Puerto interno del contenedor
ENV PORT=8080
EXPOSE 8080

# Arranque simple para laboratorio
CMD php artisan serve --host 0.0.0.0 --port $PORT
