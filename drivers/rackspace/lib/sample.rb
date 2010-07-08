#
# Author: Michael Neale
# Monkey scratchings to manipulate rackspace cloud
#

require 'rackspace_client'
rs_client = RackspaceClient.new(ARGV[0], ARGV[1])
rs_client.list_flavors.each { |e| puts e['name']  + " --> " + e['id'].to_s}

rs_client.list_images.each { |e| puts e['name'] + " --> " + e['status'] + " --> " + e['id'].to_s }

instances = rs_client.list_instances
if (instances.size > 0) then
  instances.each { |e| puts e['id'].to_s  + " ---> " + e['name'] + " ---> " + e['status'] }
else
  puts "we should start something up"
  #resp = rs_client.start_server(13, 1, "mike01") 
  #puts resp.to_s
end














