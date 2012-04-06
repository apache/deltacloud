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

class CIMI::Model::Network < CIMI::Model::Base

  text :state

  text :access

  text :bandwidth_limit

  text :traffic_priority

  text :max_traffic_delay

  text :max_traffic_loss

  text :max_traffic_jitter

  href :routing_group

  href :event_log

  array :meters do
    scalar :href
  end

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    networks=[]
    if id==:all
      networks = context.driver.networks(context.credentials, {:env=>context})
    else
      networks = context.driver.networks(context.credentials, {:id=>id, :env=>context})
    end
    networks
  end

  def self.create(request_body, context, type)
    input = (type == :xml)? XmlSimple.xml_in(request_body, {"ForceArray"=>false,"NormaliseSpace"=>2}) : JSON.parse(request_body)
    if input["networkTemplate"]["href"] #template by reference
      network_config, routing_group = get_by_reference(input, context)
    else
      if input["networkTemplate"]["networkConfig"]["href"] # configuration by reference
        network_config = NetworkConfiguration.find(context.href_id(input["networkTemplate"]["networkConfig"]["href"],:network_configurations), context)
      else #configuration by value
        network_config = get_by_value(request_body, type)
      end
      routing_group = RoutingGroup.find(context.href_id(input["networkTemplate"]["routingGroup"]["href"], :routing_groups), context)
    end
    params = {:network_config => network_config, :routing_group => routing_group, :name=>input["name"], :description=>input["description"], :env=>context}
    raise CIMI::Model::BadRequest.new("Bad request - missing required parameters. Client sent: #{request_body} which produced #{params.inspect}")  if params.has_value?(nil)
    context.driver.create_network(context.credentials, params)
  end

  def self.delete!(id, context)
    context.driver.delete_network(context.credentials, id)
  end

  def perform(action, context, &block)
    begin
      if context.driver.send(:"#{action.name}_network", context.credentials, self.name)
        block.callback :success
      else
        raise "Operation #{action.name} failed to execute on the Network #{self.name} "
      end
    rescue => e
      block.callback :failure, e.message
    end
  end

  private

  def self.get_by_reference(input, context)
    network_template = NetworkTemplate.find(context.href_id(input["networkTemplate"]["href"], :network_templates), context)
    network_config = NetworkConfiguration.find(context.href_id(network_template.network_config.href, :network_configurations), context)
    routing_group = RoutingGroup.find(context.href_id(network_template.routing_group.href, :routing_groups), context)
    return network_config, routing_group
  end

  def self.get_by_value(request_body, type)
    if type == :xml
      xml_arrays = XmlSimple.xml_in(request_body, {"NormaliseSpace"=>2})
      network_config = NetworkConfiguration.from_xml(XmlSimple.xml_out(xml_arrays["networkTemplate"][0]["networkConfig"][0]))
    else
     json = JSON.parse(request_body)
      network_config = NetworkConfiguration.from_json(JSON.generate(json["networkTemplate"]["networkConfig"]))
    end
  end

end
