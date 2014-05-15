#!/bin/bash

set -x

# make sure that all dokku container files contain ids to running docker containers
for FILE in `ls /home/dokku/*/CONTAINER`
do
  ID=`cat $FILE`
set +x
  INFO=`docker inspect $ID`
  RES=$?
set -x
  if [ "$RES" -gt 0 ] ; then
    rm $FILE
  fi
done

exit 0