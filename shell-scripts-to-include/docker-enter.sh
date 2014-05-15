#!/bin/bash

# usage:
# ./docker-attach.sh CONTAINER_ID

# for docker 0.9+
export PID=`docker inspect $1 | grep '"Pid":' | sed 's/[^0-9]//g'`
set -x
nsenter --target $PID --mount --uts --ipc --net --pid

# for docker <0.9
# lxc-attach -n `sudo docker inspect $1 | grep '"ID"' | sed 's/[^0-9a-z]//g'` /bin/bash