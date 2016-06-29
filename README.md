# What this image contains

* Apache 2.4
* PHP 5.6
* PHP Extensions:
  * gd
  * mbstring
  * mysqli
  * pdo
  * pdo_mysql
  * zip
  * imagick
  * uploadprogress
* Drush (latest stable release)
* ImageMagick
* sSMPT (Simple SMTP)

# Exposed ports

* 80 (Apache)
* 443 (SSL)

# How to use this image

One of the first things to note is that Drupal is not included with this image. That is because this image is meant to have the Drupal directory on the host and bind mounted into the container.

The example below bind mounts the Drupal root from the host (/path/to/drupal) to the /var/www/html path in the container.

```
-v /path/to/drupal:/var/www/html
```

Having the Drupal files on the host and bind mounted into the container can cause file ownership issues between the host and the container. To resolve this, a user is created in the container that is identical to the user on the host. To create the user a user name and id must be passed in.

The example below passes in the user name 'user' and the user id '1000'.

```
-e USER="user" -e UID="1000"
```

Drupal can be configured to use various database backends, so a database backend is not included and must be linked in.

The example below links the 'database_container' into our Drupal container and makes it accessible via the hostname 'db'.

```
--link database_container:db
```

sSMTP is used as the system's MTA (Mail Transfer Agent) which forwards messages to the MTA of a mailhub. sSMTP is configured to send mail to the 'mail' mailhub, so a mailhub container must be linked in to the 'mail'.

The example below links the 'mailhub_container' into our Druapl container and makes it accessible via the hostname 'mail'.

```
--link mailhub_container:mail
```

The basic pattern for starting a jantoine/drupal instance is:

```
$ docker run --name cjc_d7.curves.com_dev_www -P -v /path/to/drupal:/var/www/html -e USER="user" -e UID="1000" --link database_container:db --link mailhub_container:mail -d jantoine/drupal
```

To easily access the container via a desired hostname, create an [`nginx-proxy`](https://hub.docker.com/r/jwilder/nginx-proxy/) container and pass the hostname to the Drupal container.

The example below would make the Drupal container accessible via the example.com hostname.

```
-e VIRTUAL_HOST=example.com
```
