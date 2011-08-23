#!/bin/sh

source /usr/libexec/condor/cloud_functions

while read line; do
   name="${line%% =*}"
   value="${line#*= }"
   case $name in
     VM_XML ) VM_XML="$line" ;;
   esac
done

DISK=$(echo $VM_XML | sed "s:.*<source file='\([^']*\)'/>.*:\1:")

rm -f $DISK

exit 0
