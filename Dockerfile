FROM php:7.4-apache-bullseye

# Enable the Cache Expiration, URL Rewriting and SSL Apache modules.
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ssl-cert \
  ; \
  \
  if command -v a2enmod; then \
    a2enmod \
      expires \
      rewrite \
      ssl \
    ; \
  fi; \
  \
  if command -v a2ensite; then \
    a2ensite \
      default-ssl \
    ; \
  fi; \
  \
  rm -rf /var/lib/apt/lists/*

# Install and configure PHP dependencies and extensions.
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  # Install build dependencies.
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libpq-dev \
    libwebp-dev \
    libzip-dev \
  ; \
  # Extract the PHP source and configure extensions.
  docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg=/usr \
    --with-webp \
  ; \
  \
  docker-php-ext-install -j "$(nproc)" \
    gd \
    opcache \
    pdo_mysql \
    zip \
  ; \
  \
  # Reset apt-mark's 'manual' list so that 'purge --auto-remove' will remove all
  # build dependencies.
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark; \
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
    | awk '/=>/ { print $3 }' \
    | sort -u \
    | xargs -r dpkg-query -S \
    | cut -d: -f1 \
    | sort -u \
    | xargs -rt apt-mark manual; \
  \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  { \
  # Set recommended PHP.ini settings.
  # See https://secure.php.net/manual/en/opcache.installation.php.
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Install ImageMagick dependencies and ImageMagick.
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libmagickwand-dev \
    imagemagick \
  ; \
  rm -rf /var/lib/apt/lists/*

# Install Drush dependencies and Drush.
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    default-mysql-client \
    rsync \
  ; \
  \
  curl -OL https://github.com/drush-ops/drush/releases/download/8.4.11/drush.phar; \
  chmod +x drush.phar; \
  mv drush.phar /usr/local/bin/drush; \
  drush -y init; \
  rm -rf /var/lib/apt/lists/*

# Copy the remote file server site include configuration file.
COPY conf/apache2/conf-available/remote-file-server.conf /etc/apache2/conf-available/

# Copy scripts.
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /var/www

EXPOSE 443

CMD ["apache2-foreground"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD drush -r /var/www/html status bootstrap | grep -q Successful
