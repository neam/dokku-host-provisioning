#!/bin/bash

set -x

initial_pwd=$(pwd)
script_path=`dirname $0`

erb ../../Vagrantfile.erb > Vagrantfile
cp -r ../../shell-scripts-to-include/ shell-scripts-to-include/
erb ../../provision.sh.erb > provision.sh

