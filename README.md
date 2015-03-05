Dokku Host Provisioning
-----------------------------

Provide monitorable, debuggable and reliable production and/or staging environments using Dokku.

Provision a Dokku host that runs a specific version of Dokku, Buildstep, Docker and various plug-ins.

Uses [Vagrant](http://www.vagrantup.com/) for rsyncing files and running provisioning scripts on the remote hosts.

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

Requirements:

A Ubuntu 14.04 LTS server that you have root access to via SSH. (May work with later versions or recent Debian 8+ as well, but we have only tested it with Ubuntu 14.04)

## Dokku Plugins

* docker-options
* mariadb

## Dokku version

0.3.16-dev

## Buildstep version

Dokku 0.3.16-dev's default buildstep version.

## Docker version

1.5.0

## Working buildpacks/dockerfiles

Any buildpacks or dockerfiles compatible with Dokku 0.3.16-dev.

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

Now add deploy/push-access for yourself and set the default vhost in order to verify that your dokku host works as it should.

## Adding deploy/push-access to a developer

From a machine that has root-access to the dokku-host:

```bash
export DOKKU_HOST=$HOSTNAME
export PUBLIC_KEY=~/.ssh/id_rsa.pub
export DEVELOPER=john
cat $PUBLIC_KEY | ssh root@$DOKKU_HOST "sudo sshcommand acl-add dokku $DEVELOPER"
```

This command is successful if only a ssh key fingerprint and no error messages show up.

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

## Troubleshooting

### The default Nginx welcome page is showing instead of my deployed apps

You might need to remove the default Nginx page installed by the Nginx package / your distribution. For instance:

```bash
rm /etc/nginx/sites-enabled/default
```

Then try pushing/deploying again. If it still doesn't work, there may be some nginx configuration issue. Login to your server and run `nginx -t` to see potential issues.

### My submodules are not working

Did you follow the instructions "Supporting apps that have submodules that reference private repositories" above? If yes and there are still issues, see "Report a problem" below.

### Report a problem

If you suspect a bug in this project, report it on https://github.com/neam/dokku-host-provisioning/issues.

If you suspect a bug in general when using dokku, report the issue at https://github.com/progrium/dokku/issues, be sure to include relevant debugging information, for instance:

```
After installing and configuring a new Dokku host, I noticed that ___________ was not working properly.
I tried troubleshooting it by _________, and _________, but I suspect that this is a bug with Dokku.
I installed Dokku and relevant plugins by running the provisioning scripts found on https://github.com/neam/dokku-host-provisioning (v1.0.0)
```

## Shell scripts

The following shell scripts are available in /usr/local/bin on the dokku hosts, and may be useful:

* `docker-enter.sh` - Uses nsenter to step into a running container (unlike `docker run` which will allow you to enter a new container only)
* `limit-dokku-apps.sh` - Use to delete dokku apps en masse (to free up resources)
* `delete-dokku-apps.sh` - Used by `limit-dokku-apps.sh` to actually delete one or many apps
* `remove-phantom-docker-images-and-containers.sh` - The name says it all
* `dokku-user-allow-port-forwarding.sh` - This script enables port-forwarding for all users using ssh keys with the dokku user and thus allows non-root users to connect to the mariadb instances on the dokku host
