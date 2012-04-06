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

class CIMI::Model::VSP < CIMI::Model::Base

  text :state

  href :network

  text :bandwidth_reservation

  text :traffic_priority

  text :max_traffic_delay

  text :max_traffic_loss

  text :max_traffic_jitter

  href :event_log

  array :meters do
    scalar :href
  end

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    if id==:all
      context.driver.vsps(context.credentials, {:env=>context})
    else
      context.driver.vsps(context.credentials, {:id=>id, :env=>context})
    end
  end

  def self.create(request_body, context, type)
    input = (type == :xml)? XmlSimple.xml_in(request_body, {"ForceArray"=>false, "NormaliseSpace"=>2}) : JSON.parse(request_body)
    if input["vspTemplate"]["href"] #template by reference
      vsp_config, network = get_by_reference(input, context)
    else
      if input["vspTemplate"]["vspConfig"]["href"] # configuration by reference
        vsp_config = VSPConfiguration.find(context.href_id(input["vspTemplate"]["vspConfig"]["href"],:vsp_configurations), context)
      else #configuration by value
        vsp_config = get_by_value(request_body, type)
      end
      network = Network.find(context.href_id(input["vspTemplate"]["network"]["href"], :networks), context)
    end
    params = {:vsp_config => vsp_config, :network => network, :name=>input["name"], :description=>input["description"], :env=>context}
    raise CIMI::Model::BadRequest.new("Bad request - missing required parameters. Client sent: #{request_body} which produced #{params.inspect}")  if params.has_value?(nil)
    context.driver.create_vsp(context.credentials, params)
  end

  def self.delete!(id, context)
    context.driver.delete_vsp(context.credentials, id)
  end

  private

  def self.get_by_reference(input, context)
    vsp_template = VSPTemplate.find(context.href_id(input["vspTemplate"]["href"], :vsp_templates), context)
    vsp_config = VSPConfiguration.find(context.href_id(vsp_template.vsp_config.href, :vsp_configurations), context)
    network = Network.find(context.href_id(vsp_template.network.href, :networks), context)
    return vsp_config, network
  end

  def self.get_by_value(request_body, type)
    if type == :xml
      xml_arrays = XmlSimple.xml_in(request_body, {"NormaliseSpace"=>2})
      vsp_config = VSPConfiguration.from_xml(XmlSimple.xml_out(xml_arrays["vspTemplate"][0]["vspConfig"][0]))
    else
     json = JSON.parse(request_body)
      vsp_config = VSPConfiguration.from_json(JSON.generate(json["vspTemplate"]["vspConfig"]))
    end
  end
end
