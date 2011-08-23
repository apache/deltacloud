#!/bin/sh

source /usr/libexec/condor/cloud_functions

cd $CACHE
echo "CACHED_IMAGES=\"$(echo * | tr ' ' '\n' | grep -v -e '*' -e .qcow2 | tr '\n' ',')\""

exit 0
