#!/bin/sh

while read line; do
   line=$(echo "$line" | tr -d '"')
   name="${line%% =*}"
   value="${line#*= }"
   case $name in
     VMPARAM_VM_NAME ) NAME="$value" ;;
     VM_XML ) VM_XML="$value" ;;
   esac
done

echo $(echo $VM_XML | sed "s:{NAME}:$NAME:")
