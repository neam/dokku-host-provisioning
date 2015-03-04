Extras
======

The ordinary readme instructions use the "Managed Server" provider which allows us to provision any existing server accessible using SSH (key-based authentication):

```bash
export PROVIDER=managed
```

However, you may also start without any existing server and let vagrant create one for you:

## A new or existing Digital Ocean droplet

You need to have the vagrant digital ocean plugin installed:

```bash
vagrant plugin install vagrant-digitalocean
```

Set configuration specific to Digital Ocean:

```bash
export DIGITAL_OCEAN_TOKEN="replaceme"
export DIGITAL_OCEAN_REGION="ams2"
export SIZE=8GB
export PROVIDER=digital_ocean
```

Note: If the droplet already exists, `vagrant up` will link to the existing droplet and let you provision that. Note that it will not resize the droplet to the requested size - that was to be done manually.

## A new Rackspace Cloud Server

You need to have the vagrant rackspace plugin installed:

```bash
vagrant plugin install vagrant-rackspace
```

Set configuration specific to Rackspace:

```bash
export RACKSPACE_USERNAME="replaceme"
export RACKSPACE_API_KEY="replaceme"
export RACKSPACE_VM_REGION="lon"
export SIZE='2 GB Performance'
export PROVIDER=rackspace
```

Note: There is currently no way to link to an existing rackspace server - `vagrant up` will create a new server on Rackspace. To connect to an existing server, use the "" instructions below.

## Elsewhere

Consult the Vagrant documentation on how to deploy from scratch using other providers. Any provider that works with Vagrant should work with these configurations since we don't use any provider-specific features.

