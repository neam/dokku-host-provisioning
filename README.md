Dokku Host Provisioning
-----------------------------

Provide monitorable, debuggable and reliable production and/or staging environments using Dokku.

Uses [Vagrant](http://www.vagrantup.com/) to provisiong a Dokku host that runs a specific version of Dokku, Buildstep, Docker and various plug-ins.

Allows easy provisioning of multiple Dokku Hosts (one for staging and another for production is a good idea for instance) by generating vagrant configurations separately for each host.

Provisions:

* Specific tested versions of Docker, Dokku, Buildstep and Dokku plugins
* New Relic
* Papertrail
* Mailcatcher
* nsenter
* htop and mosh
* Swap
* A set of helper shell scripts (read below under "Shell Scripts")

## Dokku Plugins

* custom-domains
* docker-options
* mariadb
* nginx-vhosts-custom-configuration
* user-env-compile

## Dokku version

The version of Dokku provisioned is the latest master branch as of 2014-10-02 with the following additional patches that have yet to be merged into official dokku:

* [Plugin nginx-vhosts includes files in folder nginx.conf.d](https://github.com/progrium/dokku/pull/579)
* [Added create command](https://github.com/progrium/dokku/pull/599)

## Buildstep version

The version of Buildstep provisioned is the latest master branch as of 2014-10-02 while as the current master Dokku branch by default installs one from [2014-03-08](https://github.com/progrium/dokku/blob/a69f63c98c8212d393bb17ac5cc2b3960ed7c6f3/Makefile#L6).

The most notable difference is that your Dokku apps will be based on Ubuntu 14.04 LTS instead of Ubuntu 12.10 which is no longer supported and thus do not receive security updates.

## Docker version

1.2.0 is the current version of Docker provisioned.

## Working buildpacks

These buildpacks are known to work with the provisioned Dokku host:

 * [https://github.com/ddollar/heroku-buildpack-apt#7993a88465873f318486a388187764294a6a615d]()
 * [https://github.com/heroku/heroku-buildpack-nodejs#d04d0f07fe4f4b4697532877b9730f0d583acd1d]()
 * [https://github.com/neam/appsdeck-buildpack-php#83b9f6b451c29685cd0185340c2242998e986323]()
 * [https://github.com/ddollar/heroku-buildpack-multi.git]()

Other buildpacks may rely on older versions of Buildstep / Ubuntu 12.10 and needs to be updated before working.

Notably, the default PHP buildpack is currently broken. To use a the above working PHP buildpack in your project repo:

```bash
echo 'export BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git' > .env
echo 'https://github.com/neam/appsdeck-buildpack-php#83b9f6b451c29685cd0185340c2242998e986323' > .buildpacks
git add .env .buildpacks
git commit -m 'Updated PHP buildpack'
```

## Usage

### Deploying a Dokku Host as a Digital Ocean droplet

You need to have the vagrant digital ocean plugin installed:

```bash
vagrant plugin install vagrant-digitalocean
```

Some general configuration variables are necessary for the configurations before provisioning the instances:

```bash
export DIGITAL_OCEAN_TOKEN="replaceme"
export DIGITAL_OCEAN_REGION="Amsterdam 2"
export PAPERTRAIL_PORT="12345"
export NEW_RELIC_LICENSE_KEY="replaceme"
```

Set configuration that depends on DNS and performance requirements (Note: Dokku needs wildcard subdomain registration to be able to map virtual hosts based on sub-domains):

Example 1:

```bash
export VHOST=foodev.com
export SIZE=8GB
```

Example 2:

```bash
export VHOST=foo.com
export SIZE=4GB
```

To provision a dokku-enabled instance running in digital ocean:

```bash
export HOSTNAME=dokku.$VHOST
cd vagrant/dokku/
mkdir -p build/$HOSTNAME
cd build/$HOSTNAME
../../build-vagrant-config.sh
```

First time, run:

```bash
git submodule init
git submodule update --recursive
vagrant up --provider=digital_ocean
```

With an already running droplet:

```bash
vagrant provision
```

To enter the virtual machine:

```bash
vagrant ssh
```

### Deploying a Dokku Host elsewhere

The vagrant configuration currently includes support for the Digital Ocean provider only. Consult the Vagrant documentation on how to enable other providers. Any provider that works with Vagrant should work with these configurations since we don't use any Digital Ocean specific features.

## Setting the default vhost

Currently when you visit a vhost on the dokku domain that does not exist, a seemingly random dokku app deployment is served to the user. To prevent confusion, push an app to your dokku host with a name like "00-default". As long as it lists first in `ls /home/dokku/*/nginx.conf | head`, it will be used as the default nginx vhost.

Example:

```bash
mkdir /tmp/00-default-app
cd /tmp/00-default-app
git flow init --defaults
echo "This dokku-deployment does not exist" > index.php
git add index.php
git commit -m "Added index page"
export APPNAME=00-default
git push dokku@$HOSTNAME:$APPNAME develop:master
```

## Supporting apps that have submodules that reference private repositories

The dokku user on the Dokku host needs to be able to successfully authenticate by ssh key to your git host.

If your repositories are hosted on GitHub, log in as root on the Dokku host and make sure the following works by following [official GitHub instructions](https://help.github.com/articles/generating-ssh-keys/):

```bash
su dokku
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh -T git@github.com
```

(Details why this is necessary can be found in [this comment](https://github.com/progrium/dokku/issues/644#issuecomment-57082992))

## Shell scripts

The following shell scripts are available in /usr/local/bin on the dokku hosts, and may be useful:

* `docker-enter.sh` - Uses nsenter to step into a running container (unlike `docker run` which will allow you to enter a new container only)
* `limit-dokku-apps.sh` - Use to delete dokku apps en masse (to free up resources)
* `delete-dokku-apps.sh` - Used by `limit-dokku-apps.sh` to actually delete one or many apps
* `remove-phantom-docker-images-and-containers.sh` - The name says it all
* `dokku-user-allow-port-forwarding.sh` - This script enables port-forwarding for all users using ssh keys with the dokku user and thus allows non-root users to connect to the mariadb instances on the dokku host
