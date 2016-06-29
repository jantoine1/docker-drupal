FROM php:5.6-apache

# Enable the Cache Expiration, URL Rewriting and SSL Apache modules.
RUN a2enmod expires rewrite ssl

# Configure and install PHP extensions.
RUN apt-get update && apt-get install -y libjpeg-dev \
  libpng12-dev \
  libpq-dev \
  zlib1g-dev \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd \
  mbstring \
  mysqli \
  pdo \
  pdo_mysql \
  zip

# Install Upload Progress.
RUN pecl install uploadprogress \
  && echo "extension=uploadprogress.so" > /usr/local/etc/php/conf.d/ext-uploadprogress.ini

# Install ImageMagick dependencies and ImageMagick.
RUN apt-get update && apt-get install -y libmagickwand-dev \
  imagemagick \
  && pecl install imagick \
  && echo extension=imagick.so > /usr/local/etc/php/conf.d/ext-imagick.ini

# Install Drush dependencies and Drush.
RUN apt-get update && apt-get install -y mysql-client \
  rsync \
  && php -r "readfile('http://files.drush.org/drush.phar');" > drush \
  && chmod +x drush \
  && mv drush /usr/local/bin \
  && drush -y init

# Install sSMTP (Simple SMTP) and configure it to allow the 'From: address' to
# be overridden. Also inform PHP where the sendmail program can be found.
RUN apt-get update && apt-get install -y ssmtp \
  mailutils \
  && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
  && echo "sendmail_path = \"/usr/sbin/sendmail -t -i\"" >> /usr/local/etc/php/php.ini

# Copy scripts.
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
