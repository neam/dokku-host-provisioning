#!/bin/bash

# Usage: ./limit-dokku-apps.sh <limit> <include-regex> <exclude-regex>

# Kills all but the <limit> most recent containers that matches the <regex> against the list of folders in /home/dokku
# Use to kill off older dokku apps so that resourced can be freed up
# Useful in the case that your CI is automatically adding new commit-specific deployments

# Example: ./limit-dokku-apps.sh 3 'develop' 'foo'

set -x

# fail on any error
set -o errexit

# config

LIMIT=$1
GREPARGS=$2
GREPARGS_EXCLUDE=$3

if [ "$GREPARGS_EXCLUDE" == "" ]; then
    GREPARGS_EXCLUDE="dontexcludeanythingzxcvasdfqwer"
fi

# logic

cd /home/dokku
APPS=`ls -dlt */ | grep "$GREPARGS" | grep -v "$GREPARGS_EXCLUDE" | wc | awk '{ print $1 }'`
let KILL=APPS-LIMIT

echo "$APPS dokku apps matching regex \"$GREPARGS\" exclude \"$GREPARGS_EXCLUDE\""
ls -dlt */ | grep "$GREPARGS" | grep -v "$GREPARGS_EXCLUDE"
echo

if [ "$KILL" -gt 0 ] ; then

    # remove all but the LIMIT newest apps
    ls -dt */ | grep "$GREPARGS" | grep -v "$GREPARGS_EXCLUDE" | awk '{ print $1 }' | tail -n "$KILL" | sed 's/\///' | xargs delete-dokku-apps.sh

    # perform necessary clean-up for the apps be able to rebuild
    #`dirname $0`/remove-cid-files-that-dont-have-active-containers.sh

    # remove phantom docker images and containers
    docker ps | grep -v mariadb | grep -v progrium | grep -v ubuntu | grep -v CONTAINER | awk '{ print $1 }' | xargs docker rm -f
    docker ps -a | grep Exited | grep -v CONTAINER | awk '{ print $1 }' | xargs docker rm -f
    docker images | grep '<none>' | awk '{ print $3 }' | xargs docker rmi -f

fi

exit 0