#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# If the html directory doesn't exist or is empty.
if [[ ! -d html || ! $(ls -A html) ]]; then
  # Build the Drupal project.
  composer create-project drupal-composer/drupal-project:8.x-dev /tmp/drupal -s dev --prefer-dist -n
  rsync -a /tmp/drupal/ /var/www/
  rm -fr /tmp/drupal html
  ln -s web html
fi

exec "$@"
