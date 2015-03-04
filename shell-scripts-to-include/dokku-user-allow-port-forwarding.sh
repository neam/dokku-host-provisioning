#!/bin/bash

# This script enables port-forwarding for all users using ssh keys with the dokku user
# and thus allows non-root users to connect to the mariadb instances on the dokku host

set -x
sed -i s/,no-port-forwarding//g /home/dokku/.ssh/authorized_keys

exit 0