#!/bin/bash

set -x

initial_pwd=$(pwd)
script_path=`dirname $0`

erb ../../Vagrantfile.erb > Vagrantfile
cp -r ../../shell-scripts-to-include/ shell-scripts-to-include/

export DOKKU_MD_PLUGIN_REV=$(cd $script_path/vendor/dokku-md-plugin;git rev-parse --verify --short=7 HEAD)

erb ../../provision.sh.erb > provision.sh

