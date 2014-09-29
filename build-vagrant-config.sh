#!/bin/bash

set -x

initial_pwd=$(pwd)
script_path=`dirname $0`

erb ../../Vagrantfile.erb > Vagrantfile
rm -r shell-scripts-to-include/
cp -r ../../shell-scripts-to-include/ shell-scripts-to-include/
rm -r vendor/
cp -r ../../vendor/ vendor/
erb ../../provision.sh.erb > provision.sh

