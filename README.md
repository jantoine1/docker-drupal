[![DockerPulls](https://img.shields.io/docker/pulls/jantoine/drupal.svg)](https://registry.hub.docker.com/u/jantoine/drupal/)
[![DockerStars](https://img.shields.io/docker/stars/jantoine/drupal.svg)](https://registry.hub.docker.com/u/jantoine/drupal/)

# What this image contains

* Apache 2.4
* Composer (latest stable release)
* Drupal* (latest stable release)
* Drush (latest stable release)
* ImageMagick
* PHP (latest stable release)
* PHP Extensions:
  * exif
  * gd
  * mbstring
  * mysqli
  * opcache
  * pdo
  * pdo_mysql
  * uploadprogress
  * zip
* sSMPT (Simple SMTP)

***Drupal is NOT included with this image, but is installed upon creation of a container from this image, only if the /var/www/html directory is empty. The pros are that the image footprint is kept small and Drupal can either be bind mounted from the host or installed in the container. The con is that if Drupal is not bind mounted from the host, it can take several minutes for Drupal to finish installing when new containers are created. When the containers 'State:Health:Status' property is 'healthy', Drupal is installed and ready to serve requests.**

# Exposed ports

* 80 (HTTP)
* 443 (HTTPS)

# How to use this image

This image serves Drupal from the /var/www/html folder. This first example bind mounts an existing Drupal installation on the host (/path/to/drupal) to the /var/www/html path in the container.

```
-v /path/to/drupal:/var/www/html
```

This second example bind mounts the parent directory of a Drupal installation on the host (/path/to/drupal/parent) to the /var/www path in the container, with Drupal being installed in the 'html' sub-directory.

```
-v /path/to/drupal/parent:/var/www
```

If a Drupal installation is not bind mounted to the container leaving the /var/www/html directory empty, the "Composer template for Drupal projects" (https://github.com/drupal-composer/drupal-project) will be installed to the /var/www directory and and symlink will be created from the 'web' directory to the 'html' directory.

Having the Drupal files on the host and bind mounted into the container can cause file ownership issues between the host and the container. To resolve this, a user is created in the container that is identical to the user on the host. To create the user, a user name and id must be passed in. The example below passes in the user name 'user' and the user id '1000'.

```
-e USER="user" -e UID="1000"
```

Drupal can be configured to use various database backends, so a database backend is not included and must be linked in. The example below links the 'database_container' into our Drupal container and makes it accessible via the hostname 'db'.

```
--link database_container:db
```

sSMTP is used as the system's MTA (Mail Transfer Agent) which forwards messages to the MTA of a mailhub. sSMTP is configured to send mail to a mailhub accessible via the 'mail' hostname. The example below links the 'mailhub_container' into our Druapl container and makes it accessible via the hostname 'mail'.

```
--link mailhub_container:mail
```

The basic pattern for starting a jantoine/drupal instance is:

```
$ docker run --name drupal_container -P -v /path/to/drupal:/var/www/html -e USER="user" -e UID="1000" --link database_container:db --link mailhub_container:mail -d jantoine/drupal
```

To easily access the container via a desired hostname, create an [`nginx-proxy`](https://hub.docker.com/r/jwilder/nginx-proxy/) container and pass the hostname to the Drupal container.

The example below would make the Drupal container accessible via the example.com hostname.

```
-e VIRTUAL_HOST=example.com
```
