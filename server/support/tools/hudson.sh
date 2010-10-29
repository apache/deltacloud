#!/bin/bash

# Setup environment
#source /home/hudson/.rvm/scripts/rvm
PATH=/home/hudson/.rvm/gems/ruby-1.8.7-p302@deltacloud/bin:$PATH

rvm 1.8.7@deltacloud
rvm list

echo $GEM_HOME
echo $GEM_PATH
echo $PATH

# Execute tests
cd deltacloud/trunk/client && rake fixtures:clean && rake fixtures
cd ../tests
API_DRIVER="mock" rake junit
API_DRIVER="ec2" rake junit
cd ../server
rake ci:setup:testunit test
