#!/bin/bash

# Setup environment
#source /home/hudson/.rvm/scripts/rvm
PATH=/home/hudson/.rvm/gems/ruby-1.8.7-p302@deltacloud/bin:$PATH
rvm use "ruby-1.8.7"

# Execute tests
cd deltacloud/trunk/client && rake fixtures:clean && rake fixtures
cd ../tests
API_DRIVER="mock" rake junit
API_DRIVER="ec2" rake junit
cd ../server
rake ci:setup:testunit test
