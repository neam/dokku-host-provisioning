Dokku Host Provisioning
-----------------------------

Provide monitorable, debuggable and reliable production and/or staging environments using Dokku.

Uses [Vagrant](http://www.vagrantup.com/) to create and update digital ocean droplets that runs a specific version of Dokku, Docker and various plug-ins.

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

## Dokku Patches

The version of Dokku provisioned is the latest master branch as of 2014-10-02 with the following additional patches that have yet to be merged into official dokku:

* [Plugin nginx-vhosts includes files in folder nginx.conf.d](https://github.com/progrium/dokku/pull/579)
* [Added create command](https://github.com/progrium/dokku/pull/599)

## Usage

To use the vagrant configurations, you need the vagrant digital ocean plugin:

    vagrant plugin install vagrant-digitalocean

Some general configuration variables are necessary for the configurations before provisioning the instances:

    export DIGITAL_OCEAN_TOKEN="replaceme"
    export DIGITAL_OCEAN_REGION="Amsterdam 2"
    export PAPERTRAIL_PORT="12345"
    export NEW_RELIC_LICENSE_KEY="replaceme"

Set configuration that depends on DNS and performance requirements (Note: Dokku needs wildcard subdomain registration to be able to map virtual hosts based on sub-domains):

Example 1:

    export VHOST=foodev.com
    export SIZE=8GB

Example 2:

    export VHOST=foo.com
    export SIZE=4GB

To provision a dokku-enabled instance running in digital ocean:

    export HOSTNAME=dokku.$VHOST
    cd vagrant/dokku/
    mkdir -p build/$HOSTNAME
    cd build/$HOSTNAME
    ../../build-vagrant-config.sh

First time, run:

    git submodule init
    git submodule update --recursive
    vagrant up --provider=digital_ocean

With an already running droplet:

    vagrant provision

To enter the virtual machine:

    vagrant ssh

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

## Shell scripts

The following shell scripts are available in /usr/local/bin on the dokku hosts, and may be useful:

* docker-enter.sh - Uses nsenter to step into a running container
* remove-cid-files-that-dont-have-active-containers.sh - Makes sure that all dokku container files contain ids to running docker containers
* limit-dokku-deployments.sh - Use to limit commit-specific deployments
