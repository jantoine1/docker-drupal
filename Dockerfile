FROM ubuntu:precise

# Install and configure Apache HTTP Server.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y apache2 \
  # Enable the Cache Expiration, URL Rewriting and SSL Apache modules.
  && a2enmod expires rewrite ssl \
  # Create an html directory for the DocumentRoot Directory.
  && mkdir /var/www/html \
  # Enable the default-ssl VirtualHost.
  && a2ensite default-ssl

# Install PHP dependencies and PHP.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y php5 \
  curl \
  make \
  php5-cli \
  php5-curl \
  php5-gd \
  php5-mysql \
  php-pear \
  php5-dev

# Install Upload Progress.
RUN pecl install uploadprogress \
  && echo "extension=uploadprogress.so" > /etc/php5/apache2/conf.d/uploadprogress.ini

# Install ImageMagick dependencies and ImageMagick.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y libmagickwand-dev \
  imagemagick \
  php5-imagick

# Install Composer.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer

# Install Drush dependencies and Drush.
RUN apt-get update && apt-get install -y mysql-client \
  rsync \
  && composer global require drush/drush:7.* \
  && sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc \
  && . $HOME/.bashrc \
  && drush status \
  && drush dl registry_rebuild

# Install sSMTP (Simple SMTP) and configure it to allow the 'From: address' to
# be overridden. Also inform PHP where the sendmail program can be found.
RUN apt-get update && apt-get install -y ssmtp \
  mailutils \
  && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
  && echo "sendmail_path = \"/usr/sbin/sendmail -t -i\"" >> /etc/php5/apache2/php.ini

# Initialize Apache HTTP Server.
RUN service apache2 restart

# Copy custom configuration files.
COPY conf/apache2/sites-available/default /etc/apache2/sites-available/
COPY conf/apache2/sites-available/default-ssl /etc/apache2/sites-available/
COPY conf/php5/apache2/php.ini /etc/php5/apache2/

WORKDIR /var/www/html

EXPOSE 80 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
