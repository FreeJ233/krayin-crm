# 基于官方 PHP 8.1 FPM 镜像
FROM php:8.1-fpm

# 安装必要的扩展和工具
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql

# 安装 Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 设置工作目录
WORKDIR /var/www/html

# 克隆 Krayin CRM 源码
RUN git clone https://github.com/krayin/laravel-crm.git .

# 初始化 Krayin CRM
RUN composer install && \
    cp .env.example .env && \
    php artisan key:generate && \
    php artisan migrate --force && \
    php artisan db:seed --force && \
    php artisan storage:link

# 设置文件权限
RUN chmod -R 775 storage bootstrap/cache

CMD ["php-fpm"]
