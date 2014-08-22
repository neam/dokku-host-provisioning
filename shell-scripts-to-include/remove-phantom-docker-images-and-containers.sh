#!/bin/bash

docker ps | grep -v mariadb | grep -v progrium | grep -v ubuntu | grep -v CONTAINER | awk '{ print $1 }' | xargs docker rm -f
docker ps -a | grep Exited | grep -v CONTAINER | awk '{ print $1 }' | xargs docker rm -f
docker images | awk '{ print $3 }' | xargs docker rmi
docker images | grep '<none>' | awk '{ print $3 }' | xargs docker rmi -f

exit 0