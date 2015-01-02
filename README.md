Dokku Host Provisioning - 1.0.0
-----------------------------

Provide monitorable, debuggable and reliable production and/or staging environments using Dokku.

Uses [Vagrant](http://www.vagrantup.com/) to provision Dokku hosts that runs a specific version of Dokku, Buildstep, Docker and various plug-ins.

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
* deployment-keys & hostkeys

## Dokku version

The version of Dokku provisioned is the latest master branch as of 2014-10-02 with the following additional patches that have yet to be merged into official dokku:

* [Plugin nginx-vhosts includes files in folder nginx.conf.d](https://github.com/progrium/dokku/pull/579)
* [Added create command](https://github.com/progrium/dokku/pull/599)

This corresponds loosely to Dokku version 0.3.1 in functionality.

## Buildstep version

The version of Buildstep provisioned is the latest master branch as of 2014-10-02 while as [the current (last checked 2015-01-02) master Dokku branch by default installs one from 2014-03-08](https://github.com/progrium/dokku/blob/f6b7b62b15250e1e396d2363ef49b8c1784888c3/Makefile#L6).

The most notable difference is that your Dokku apps will be based on Ubuntu 14.04 LTS instead of Ubuntu 12.10 which is no longer supported and thus do not receive security updates.

## Docker version

1.2.0 is the current version of Docker provisioned.

## Working buildpacks

These buildpacks are known to work with the provisioned Dokku host:

 * [https://github.com/ddollar/heroku-buildpack-apt#7993a88465873f318486a388187764294a6a615d](https://github.com/ddollar/heroku-buildpack-apt#7993a88465873f318486a388187764294a6a615d)
 * [https://github.com/heroku/heroku-buildpack-nodejs#d04d0f07fe4f4b4697532877b9730f0d583acd1d](https://github.com/heroku/heroku-buildpack-nodejs#d04d0f07fe4f4b4697532877b9730f0d583acd1d)
 * [https://github.com/neam/appsdeck-buildpack-php#83b9f6b451c29685cd0185340c2242998e986323](https://github.com/neam/appsdeck-buildpack-php#83b9f6b451c29685cd0185340c2242998e986323)
 * [https://github.com/ddollar/heroku-buildpack-multi.git](https://github.com/ddollar/heroku-buildpack-multi.git)

Other buildpacks may rely on older versions of Buildstep / Ubuntu 12.10 and needs to be updated before working.

Notably, the default PHP buildpack is currently broken. To use the working PHP buildpack listed above in your project repo:

1. Set your app to use the Multi-buildpack (which supports version pinning).

```bash
dokku create <appname>
dokku config:set <appname> BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
```

2. Add a `.buildpacks` file that instructs the Multi-buildpack to use the tested version of the above buildpack:

```bash
echo 'https://github.com/neam/appsdeck-buildpack-php#83b9f6b451c29685cd0185340c2242998e986323' > .buildpacks
git add .buildpacks
git commit -m 'Updated PHP buildpack'
```

Note: You can use all of the above buildpacks at once, so that composer deps, node, npm and apt dependencies all are installed by using the following as the contents of your `.buildpacks` file:

```
https://github.com/ddollar/heroku-buildpack-apt#7993a88465873f318486a388187764294a6a615d
https://github.com/heroku/heroku-buildpack-nodejs#d04d0f07fe4f4b4697532877b9730f0d583acd1d
https://github.com/neam/appsdeck-buildpack-php#313f71652cd79f6a6a045710ea6ae210a74cc4d2
```

## Usage

The general workflow:

1. Set configuration via environment variables in the shell
2. Generate a configuration for a specific server
3. Provision the server

Repeat steps 2 and 3 for every dokku host you wish to provision.

Anytime you want to change the configuration, updated libraries or similar, you run the steps again.

### Provisioning a Dokku Host

First, make sure you have key-based SSH authentication set-up against your target server.

Some general configuration variables are necessary for the configurations before provisioning:

```bash
export PROVIDER=managed
export PAPERTRAIL_PORT="12345"
export NEW_RELIC_LICENSE_KEY="replaceme"
```

Set configuration that depends on DNS (Note: Dokku needs wildcard subdomain registration to be able to map virtual hosts based on sub-domains):

Example 1:

```bash
export VHOST=foodev.com
```

Example 2:

```bash
export VHOST=foo.com
```

To build vagrant configuration for a particular dokku host:

```bash
export HOSTNAME=dokku.$VHOST
mkdir -p build/$HOSTNAME
git submodule init
git submodule update --recursive
cd build/$HOSTNAME
../../build-vagrant-config.sh
```

Then, if this is the first run:

```bash
vagrant up --provider=$PROVIDER
```

Then, when a server is up and running, it needs to be provisioned (this command can also be run on existing deployments to update the deployment):

```bash
vagrant provision
```

To enter the virtual machine:

```bash
vagrant ssh
```

## Adding deploy/push-access to a developer

From a machine that has root-access to the dokku-host:

```bash
export DOKKU_HOST=$HOSTNAME
export PUBLIC_KEY=~/.ssh/id_rsa.pub
export DEVELOPER=john
cat $PUBLIC_KEY | ssh root@$DOKKU_HOST "sudo sshcommand acl-add dokku $DEVELOPER"
```

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

If your repositories are hosted on Bitbucket, log in as root on the Dokku host and make sure the following works:

```bash
su dokku
ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
ssh -T git@bitbucket.org
```

(Details why this is necessary can be found in [this comment](https://github.com/progrium/dokku/issues/644#issuecomment-57082992))

## Shell scripts

The following shell scripts are available in /usr/local/bin on the dokku hosts, and may be useful:

* `docker-enter.sh` - Uses nsenter to step into a running container (unlike `docker run` which will allow you to enter a new container only)
* `limit-dokku-apps.sh` - Use to delete dokku apps en masse (to free up resources)
* `delete-dokku-apps.sh` - Used by `limit-dokku-apps.sh` to actually delete one or many apps
* `remove-phantom-docker-images-and-containers.sh` - The name says it all
* `dokku-user-allow-port-forwarding.sh` - This script enables port-forwarding for all users using ssh keys with the dokku user and thus allows non-root users to connect to the mariadb instances on the dokku host
