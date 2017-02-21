#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# If required environment variables are not set.
if [[ -z "$USER" || -z "$UID" ]]; then
  if [[ -z "$USER" ]]; then
    echo "Need to set USER"
  fi

  if [[ -z "$UID" ]]; then
    echo "Need to set UID"
  fi

  exit 1
fi

# If the user has not already been created.
if [[ ! $(id -u $USER) =~ ^-?[0-9]+$ ]]; then
  # Create the user.
  adduser --group --shell /bin/bash --system --uid $UID $USER

  # Add the www-data user to the $USER group.
  usermod -a -G $USER www-data
fi

# If the html directory doesn't exist or is empty.
if [[ ! -d html || ! $(ls -A html) ]]; then
  # Install Drupal as $USER.
  runuser $USER << EOF
    composer create-project drupal-composer/drupal-project:8.x-dev /tmp/drupal -s dev --prefer-dist -n
    rsync -a /tmp/drupal/ /var/www/
    rm -fr /tmp/drupal html
    ln -s web html
EOF
fi

exec "$@"
