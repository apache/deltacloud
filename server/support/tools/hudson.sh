#!/bin/bash

# Setup environment
#source /home/hudson/.rvm/scripts/rvm
rvm 1.8.7@deltacloud

# Execute tests
cd deltacloud/trunk/client && rake fixtures:clean && rake fixtures
cd ../tests
API_DRIVER="mock" rake junit
API_DRIVER="ec2" rake junit
cd ../server
rake ci:setup:testunit test
