# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

class CIMI::Model::NetworkPortCollection < CIMI::Model::Base

  act_as_root_entity :network_port

  text :count

  #add member array:
  self << CIMI::Model::NetworkPort

  def self.default(context)
    network_ports = CIMI::Model::NetworkPort.all(context)
    self.new(
      :id => context.network_ports_url,
      :name => 'default',
      :created => Time.now,
      :description => "#{context.driver.name.capitalize} NetworkPortCollection",
      :count => network_ports.size,
      :network_ports => network_ports
    )
  end

  def self.for_network(network_id, context)
    net_url = context.network_url(network_id)
    network_ports = CIMI::Model::NetworkPort.all(context)
    ports_collection = network_ports.inject([]){|res, current| res << current if current.network.href == net_url ; res}
    self.new(
      :id => net_url+"/network_ports",
      :name => 'default',
      :created => Time.now,
      :description => "#{context.driver.name.capitalize} NetworkPortCollection",
      :count => ports_collection.size,
      :network_ports => ports_collection
    )
  end

end
