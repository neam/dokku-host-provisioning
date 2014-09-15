Dokku Vagrant Configuration
-----------------------------

Uses [Vagrant](http://www.vagrantup.com/) to create and update digital ocean droplets that runs a specific version of Dokku, Docker and various plug-ins.

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
    erb ../../Vagrantfile.erb > Vagrantfile
    erb ../../provision.sh.erb > provision.sh
    cp -r ../../shell-scripts-to-include/ shell-scripts-to-include/

First time, run:

    vagrant up --provider=digital_ocean

With an already running droplet:

    vagrant provision

To enter the virtual machine:

    vagrant ssh

## Setting the default vhost

Push an app to your dokku host with a name like "00-default". As long as it lists first in `ls /home/dokku/*/nginx.conf | head`, it will be used as the default nginx vhost.

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
