FROM php:apache

# Enable the Cache Expiration, URL Rewriting and SSL Apache modules.
RUN apt update \
  && apt install -y \
    ssl-cert \
  && a2enmod \
    expires \
    rewrite \
    ssl \
  && a2ensite \
    default-ssl

# Install and configure PHP dependencies and extensions.
RUN apt update \
  && apt install -y \
    libjpeg-dev \
    libpng12-dev \
    libpq-dev \
    zlib1g-dev \
  # Extract the PHP source and configure extensions.
  && docker-php-ext-configure \
    gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  # Include the PECL Upload Progress PHP extension source.
  && mkdir /usr/src/php/ext/uploadprogress \
  && curl -fSL https://github.com/php/pecl-php-uploadprogress/archive/master.tar.gz | tar xvz -C /usr/src/php/ext/uploadprogress --strip 1 \
  && docker-php-ext-install \
    exif \
    gd \
    mbstring \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    uploadprogress \
    zip \
  && { \
    # Set the timezone.
    echo "date.timezone = 'America/Los_Angeles'"; \
  } >> /usr/local/etc/php/php.ini \
  && { \
    # Set recommended PHP.ini settings.
    # See https://secure.php.net/manual/en/opcache.installation.php.
    echo 'opcache.memory_consumption = 128'; \
    echo 'opcache.interned_strings_buffer = 8'; \
    echo 'opcache.max_accelerated_files = 4000'; \
    echo 'opcache.revalidate_freq = 60'; \
    echo 'opcache.fast_shutdown = 1'; \
    echo 'opcache.enable_cli = 1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Install ImageMagick dependencies and ImageMagick.
RUN apt update \
  && apt install -y \
    libmagickwand-dev \
    imagemagick

# Install Drush dependencies and Drush.
RUN apt update \
  && apt install -y \
    mysql-client \
    rsync \
  && php -r "readfile('http://files.drush.org/drush.phar');" > drush \
  && chmod +x drush \
  && mv drush /usr/local/bin \
  && drush -y init

# Install Composer.
RUN COMPOSER_SIGNATURE=$(curl https://composer.github.io/installer.sig) \
  && curl -fSL "https://getcomposer.org/installer" -o composer-setup.php \
  && echo "${COMPOSER_SIGNATURE} composer-setup.php" | sha384sum -c - \
  && php composer-setup.php \
  && rm composer-setup.php \
  && mv composer.phar /usr/local/bin/composer

# Install sSMTP (Simple SMTP) and configure it to allow the 'From: address' to
# be overridden. Also inform PHP where the sendmail program can be found.
RUN apt update \
  && apt install -y \
    ssmtp \
    mailutils \
  && echo "FromLineOverride = YES" >> /etc/ssmtp/ssmtp.conf \
  && echo "sendmail_path = \"/usr/sbin/sendmail -t -i\"" >> /usr/local/etc/php/php.ini

# Copy scripts.
COPY entrypoint.sh /

WORKDIR /var/www

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f $(hostname) || exit 1
