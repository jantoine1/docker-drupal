#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# If a remote file server has been specified.
if [[ ! -z "$REMOTE_FILE_SERVER" ]]; then
  # If a remote file server has not been set in the default apache conf file.
  if ! grep -q remote-file-server.conf /etc/apache2/sites-available/000-default.conf; then
    # Include the remote file server configuration file.
    sed -i '/<\/VirtualHost>/i \
      \tInclude conf-available/remote-file-server.conf' /etc/apache2/sites-available/000-default.conf
  fi

  # If a remote file server has not been set in the default-ssl apache conf
  # file.
  if ! grep -q remote-file-server.conf /etc/apache2/sites-available/default-ssl.conf; then
    # Include the remote file server configuration file.
    sed -i '/<\/VirtualHost>/i \
      \t\tInclude conf-available/remote-file-server.conf' /etc/apache2/sites-available/default-ssl.conf
  fi
fi

exec "$@"
