#!/bin/bash

set -x

initial_pwd=$(pwd)
script_path=`dirname $0`

export DOCKER_VERSION="1.2.0"
export DOKKU_REVISION="$(cd $script_path/vendor/dokku;git rev-parse --verify HEAD)"
export BUILDSTEP_REVISION="$(cd $script_path/vendor/buildstep;git rev-parse --verify HEAD)"

erb ../../Vagrantfile.erb > Vagrantfile
rm -r shell-scripts-to-include/
cp -r ../../shell-scripts-to-include/ shell-scripts-to-include/
rm -r vendor/
cp -r ../../vendor/ vendor/

echo $DOKKU_REVISION > vendor/dokku/REVISION
echo $BUILDSTEP_REVISION > vendor/buildstep/REVISION

erb ../../provision.sh.erb > provision.sh

