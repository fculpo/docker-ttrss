# TTRSS

This repo hosts Dockerfiles needed to run a fully containerized [Tiny Tiny RSS](http://tt-rss.org) feed reader.

The 3 components are:

* A PHP FPM container
* A Nginx container
* A feed update daemon container


You can access it through an easy to use webinterface on your desktop, your mobile browser or using one of the available apps.

## About Tiny Tiny RSS

> *From [the official readme](http://tt-rss.org/redmine/projects/tt-rss/wiki):*

Tiny Tiny RSS is an open source web-based news feed (RSS/Atom) reader and aggregator, designed to allow you to read news from any location,
while feeling as close to a real desktop application as possible.

![](https://tt-rss.org/images/ttrss/18.12/1812-shot1.png)

## A not so quickstart

This repo is different than other ttrss Docker images you could find, as it separates all the components, to ensure Docker best practices.

You will also need a Postgresql or Mysql database (container or other).

Thus, this will be a 4 containers deployment.

## Configuration options

You can choose between providing your own ```config.php``` file or use environment variables to autoconfigure the instance.

### Providing your own config.php file

If you provide your own file, you need to add it as a Docker volume to the ```fpm``` and ```daemon``` containers.

```
docker run -d --name ttrss-fpm \
    -v your-config.php:/var/www/html/config.php fculpo/ttrss:fpm

docker run -d --name ttrss-daemon \
    -v your-config.php:/var/www/html/config.php fculpo/ttrss:daemon
```

### Using environment variables

To simplify configuration, you can also provide the following environment variables to let the containers autoconfigure:

```
SELF_URL_PATH = public URL of the TTRSS instance (http(s)://somedomain.com)
DB_TYPE = pgsql or mysql
DB_HOST = url of the db
DB_PORT = port of the database
DB_NAME = name of the database to use    
DB_USER = db username
DB_PASS = db password
AUTH_METHOD = internal or ldap (see below)
```

### Database superuser

If not using your own ```config.php```, when you run ttrss, it will check your database setup. If it can not connect using the above configuration, it will automatically try to create a new database and user.

For this to work, it will need a superuser account that is permitted to create a new database and user. It assumes the following default configuration, which can be changed by passing the following additional variables:

```
DB_ENV_USER = root username of the db
DB_ENV_PASS = db root password (needed to create database if not found) 
```

## Authentication

This container supports internal and ldap authentication by setting `AUTH_METHOD` to `internal` or `ldap`. Default is `internal`.

If you set `AUTH_METHOD=ldap`, adapt the following lines to your environment and add them to your ```config.php```, or provide the same environment variables to the ```fpm``` container:

```
// Required parameters:
define('LDAP_AUTH_SERVER_URI', 'ldap://localhost:389/');
define('LDAP_AUTH_USETLS', FALSE); // Enable StartTLS Support for ldap://
define('LDAP_AUTH_ALLOW_UNTRUSTED_CERT', TRUE); // Allows untrusted certificate
define('LDAP_AUTH_BASEDN', 'dc=example,dc=com');
define('LDAP_AUTH_ANONYMOUSBEFOREBIND', FALSE);
// ??? will be replaced with the entered username(escaped) at login
define('LDAP_AUTH_SEARCHFILTER', '(&(objectClass=person)(uid=???))');

// Optional configuration
define('LDAP_AUTH_BINDDN', 'cn=serviceaccount,dc=example,dc=com');
define('LDAP_AUTH_BINDPW', 'ServiceAccountsPassword');
define('LDAP_AUTH_LOGIN_ATTRIB', 'uid');
define('LDAP_AUTH_LOG_ATTEMPTS', FALSE);

// Enable Debug Logging
define('LDAP_AUTH_DEBUG', FALSE);
```

For more information consult https://github.com/hydrian/TTRSS-Auth-LDAP

## Deployment options

Best way to use these Docker images are eitheir docker-compose or Kubernetes.

### Docker / Compose

TODO

### Kubernetes

TODO

## Accessing your webinterface

Once deployed your instance should be available at your configured ```SELF_URL_PATH``` url (depending of your environment, you probably will need to configure  DNS / reverse proxy, etc...)

The default login credentials on a freshly installed instance are:

* Username: admin
* Password: password

Obviously, you're recommended to change these as soon as possible.
