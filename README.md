[![DockerPulls](https://img.shields.io/docker/pulls/jantoine/drupal.svg)](https://registry.hub.docker.com/u/jantoine/drupal/)
[![DockerStars](https://img.shields.io/docker/stars/jantoine/drupal.svg)](https://registry.hub.docker.com/u/jantoine/drupal/)

# What this image contains

**Drupal is NOT included with this image! See [How to use this image](#how).**

* Apache 2.4
* Drush Launcher
* ImageMagick
* PHP (latest 7.2 release)
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

# Exposed ports

* 80 (HTTP)
* 443 (HTTPS)

# <a name="how"></a>How to use this image

This image is designed to serve a Drupal project, built from the [Composer template for Drupal projects](https://github.com/drupal-composer/drupal-project), from the /var/www/html directory. Below are two example methods for getting a Drupal installation into the /var/www/html directory.

## Copy a drupal installation while creating a project-specific image

This is the recommended method for production and allows for rapidly deploying drupal containers.

The example Dockerfile below copies an existing Drupal installation from the host (/path/to/drupal) to the /var/www/html path inside the project-specific image.

```dockerfile
FROM jantoine/drupal:8

# Copy the Drupal files into the container.
COPY /path/to/drupal /var/www/html
RUN chown -R www-data:www-data /var/www/html
```

## Bind mount a drupal installation from the host

This is the recommended method for development and allows changes to files on the host to be reflected inside the container.

This first example bind mounts an existing Drupal installation on the host (/path/to/drupal) to the /var/www/html path in the container.

```bash
-v /path/to/drupal:/var/www/html
```

This second example bind mounts the parent directory of a Drupal installation on the host (/path/to/drupal/parent) to the /var/www path in the container, with Drupal being installed in the 'html' sub-directory.

```bash
-v /path/to/drupal/parent:/var/www
```

Drupal can be configured to use various database backends, so a database backend is not included and must be linked in. The example below links the 'database_container' into our Drupal container and makes it accessible via the hostname 'db'.

```bash
--link database_container:db
```

sSMTP is used as the system's MTA (Mail Transfer Agent) which forwards messages to the MTA of a mailhub. sSMTP is configured to send mail to a mailhub accessible via the 'mail' hostname. The example below links the 'mailhub_container' into our Druapl container and makes it accessible via the hostname 'mail'.

```bash
--link mailhub_container:mail
```

The basic pattern for starting a jantoine/drupal instance is:

```bash
$ docker run --name drupal_container -P -v /path/to/drupal:/var/www/html --link database_container:db --link mailhub_container:mail -d jantoine/drupal
```

To easily access the container via a desired hostname, create an [`nginx-proxy`](https://hub.docker.com/r/jwilder/nginx-proxy/) container and pass the hostname to the Drupal container.

The example below would make the Drupal container accessible via the example.com hostname.

```bash
-e VIRTUAL_HOST=example.com
```
