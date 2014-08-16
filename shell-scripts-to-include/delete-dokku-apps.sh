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

    # move remains from mariadb to a trash folder for inspection before they are deleted
    set +o errexit
    mkdir /home/dokku/.mariadb-trash
    mv /home/dokku/.mariadb/*$APPNAME /home/dokku/.mariadb-trash/
    set -o errexit

done