#!/bin/sh
#
## TODO: This fiel will be replaced by regular Rake task
#

for t in tests/*.rb; do
  ruby $t
done
