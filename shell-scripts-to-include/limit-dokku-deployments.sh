#!/bin/bash

# Usage: ./limit-dokku-deployments.sh <limit> <regex>

# Kills all but the <limit> most recent containers that matches the <regex> from the output of "docker ps"
# Use to kill off older deployments in the case that your CI or similar
# is automatically adding new commit-specific deployments

# Example: ./limit-dokku-deployments.sh 3 'dokku/travis'

set -x

# config

LIMIT=$1
GREPARGS=${@:2}

# logic

RUNNING=`docker images | grep 'dokku/' | grep "$GREPARGS" | wc | awk '{ print $1 }'`
let KILL=RUNNING-LIMIT

echo "$RUNNING docker images matching regex \"$GREPARGS\""
docker images | grep 'dokku/' | grep "$GREPARGS"
echo

if [ "$KILL" -gt 0 ] ; then

    # remove all but the LIMIT newest deployments
    docker ps | grep 'dokku/' | grep "$GREPARGS" | awk '{ print $1 }' | tail -n "$KILL" | xargs docker rm -f
    docker images | grep 'dokku/' | grep "$GREPARGS" | awk '{ print $1 }' | tail -n "$KILL" | sed 's/dokku\///' | xargs delete-dokku-apps.sh

    # perform necessary clean-up for the apps be able to rebuild
    `dirname $0`/remove-cid-files-that-dont-have-active-containers.sh

fi

exit 0