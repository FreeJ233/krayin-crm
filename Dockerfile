# 使用官方 PHP 8.1 镜像作为基础
FROM php:8.1-fpm

# 安装必要的工具和扩展
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql

# 安装 Node.js 版本 8.11.3 LTS 或更高
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs

# 安装 Composer 2.5 或更高版本
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 设置工作目录
WORKDIR /var/www/html

# 克隆 Krayin CRM 源码
RUN git clone https://github.com/krayin/laravel-crm.git .

# 安装 PHP 和前端依赖
RUN composer install && \
    npm install && \
    npm run dev

# 设置文件权限
RUN chmod -R 775 storage bootstrap/cache

# 环境变量和初始化命令
RUN cp .env.example .env && \
    php artisan key:generate && \
    php artisan migrate --force && \
    php artisan db:seed --force && \
    php artisan storage:link

CMD ["php-fpm"]
