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

class CIMI::Service::NetworkPort < CIMI::Service::Base

  def self.find(id, context)
    if id==:all
      context.driver.network_ports(context.credentials, {:env=>context})
    else
      context.driver.network_ports(context.credentials, {:id=>id, :env=>context})
    end
  end

  # FIXME: This should go into NetworkPortCreate model
  #
  def self.create(request_body, context, type)
    input = (type == :xml)? XmlSimple.xml_in(request_body, {"ForceArray"=>false, "NormaliseSpace"=>2}) : JSON.parse(request_body)
    if input["networkPortTemplate"]["href"] #template by reference
      network_port_config, network = get_by_reference(input, context)
    else
      if input["networkPortTemplate"]["networkPortConfig"]["href"] # configuration by reference
        network_port_config = CIMI::Service::NetworkPortConfiguration.find(context.href_id(input["networkPortTemplate"]["networkPortConfig"]["href"],:network_port_configurations), context)
      else #configuration by value
        network_port_config = get_by_value(request_body, type)
      end
      network = CIMI::Service::Network.find(context.href_id(input["networkPortTemplate"]["network"]["href"], :networks), context)
    end
    params = {:network_port_config => network_port_config, :network => network, :name=>input["name"], :description=>input["description"], :env=>context}
    raise CIMI::Model::BadRequest.new("Bad request - missing required parameters. Client sent: #{request_body} which produced #{params.inspect}")  if params.has_value?(nil)
    context.driver.create_network_port(context.credentials, params)
  end

  def self.delete!(id, context)
    context.driver.delete_network_port(context.credentials, id)
  end

  def perform(action, context, &block)
    begin
      if context.driver.send(:"#{action.name}_network_port", context.credentials, self.name)
        block.callback :success
      else
        raise "Operation #{action.name} failed to execute on the NetworkPort #{self.name} "
      end
    rescue => e
      block.callback :failure, e.message
    end
  end

  def self.collection_for_network(network_id, context)
    net_url = context.network_url(network_id)
    network_ports = CIMI::Service::NetworkPort.all(context)
    ports_collection = network_ports.inject([]){|res, current| res << current if current.network.href == net_url ; res}
    CIMI::Service::NetworkPortCollection.new(context, :values => {
      :id => net_url+"/network_ports",
      :name => 'default',
      :created => Time.now,
      :description => "#{context.driver.name.capitalize} NetworkPortCollection",
      :count => ports_collection.size,
      :network_ports => ports_collection
    })
  end

  private

  # FIXME: Are the methods below really needed???

  def self.get_by_reference(input, context)
    network_port_template = CIMI::Service::NetworkPortTemplate.find(context.href_id(input["networkPortTemplate"]["href"], :network_port_templates), context)
    network_port_config = CIMI::Service::NetworkPortConfiguration.find(context.href_id(network_port_template.network_port_config.href, :network_port_configurations), context)
    network = CIMI::Service::Network.find(context.href_id(network_port_template.network.href, :networks), context)
    return network_port_config, network
  end

  def self.get_by_value(request_body, type)
    if type == :xml
      xml_arrays = XmlSimple.xml_in(request_body, {"NormaliseSpace"=>2})
      network_port_config = CIMI::Service::NetworkPortConfiguration.from_xml(XmlSimple.xml_out(xml_arrays["networkPortTemplate"][0]["networkPortConfig"][0]))
    else
     json = JSON.parse(request_body)
      network_port_config = CIMI::Service::NetworkPortConfiguration.from_json(JSON.generate(json["networkPortTemplate"]["networkPortConfig"]))
    end
  end


end
