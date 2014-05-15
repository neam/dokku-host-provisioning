#!/bin/bash

# usage: ./limit-dokku-deployments.sh 3 "project1 project2 project3 project4"

set -x

# config

LIMIT=$1

# logic

for PROJECT in $2
do

    RUNNING=`docker ps | grep "\-$PROJECT\-" | wc | awk '{ print $1 }'`
    let KILL=RUNNING-LIMIT

    echo "$RUNNING commit-specific containers active for project $PROJECT"

    if [ "$KILL" -gt 0 ] ; then

        # kill all but the LIMIT newest deployments within each project
        docker ps | grep "\-$PROJECT\-" | awk '{ print $1 }' | tail -n "$KILL" | xargs docker kill

    fi

done

exit 0