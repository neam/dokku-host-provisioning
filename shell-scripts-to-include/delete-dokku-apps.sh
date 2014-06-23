#!/bin/bash

# Usage: ./delete-dokku-apps.sh appname1 appname2

# debug
set -x

# fail on any error
set -o errexit

for APPNAME in $@
do

    # delete any databases
    set +o errexit
    dokku mariadb:delete $APPNAME
    set -o errexit

    # delete the dokku app
    set +o errexit
    dokku delete $APPNAME
    set -o errexit

    # remove remaining cache-files and similar
    if [ -d /home/dokku/$APPNAME ]; then
        rm -r /home/dokku/$APPNAME
    fi

done