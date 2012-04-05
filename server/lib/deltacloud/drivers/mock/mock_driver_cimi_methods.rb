#
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
#
#Definition of CIMI methods for the mock driver - seperation from deltacloud
#API mock driver methods

module Deltacloud::Drivers::Mock

  class MockDriver < Deltacloud::BaseDriver

    def networks(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        networks = @client.load_all_cimi(:network).map{|net| CIMI::Model::Network.from_json(net)}
        networks.map{|net|convert_cimi_mock_urls(:network, net ,opts[:env])}.flatten
      else
        network = CIMI::Model::Network.from_json(@client.load_cimi(:network, opts[:id]))
        convert_cimi_mock_urls(:network, network, opts[:env])
      end
    end

    def create_network(credentials, opts={})
      check_credentials(credentials)
      id = "#{opts[:env].send("networks_url")}/#{opts[:name]}"
      net_hsh = { "id"=> id,
                  "name" => opts[:name],
                  "description" => opts[:description],
                  "created" => Time.now,
                  "state" => "STARTED",
                  "access" => opts[:network_config].access,
                  "bandwithLimit" => opts[:network_config].bandwidth_limit,
                  "trafficPriority" => opts[:network_config].traffic_priority,
                  "maxTrafficDelay" => opts[:network_config].max_traffic_delay,
                  "maxTrafficLoss" =>opts[:network_config].max_traffic_loss,
                  "maxTrafficJitter" =>opts[:network_config].max_traffic_jitter,
                  "routingGroup"=> { "href" => opts[:routing_group].id },
                  "operations" => [{"rel"=>"edit", "href"=> id},
                                   {"rel"=>"delete", "href"=> id}]    }
      network = CIMI::Model::Network.from_json(JSON.generate(net_hsh))

      @client.store_cimi(:network, network)
      network
    end

    def delete_network(credentials, id)
      check_credentials(credentials)
      @client.destroy_cimi(:network, id)
    end

    def start_network(credentials, id)
      check_credentials(credentials)
      update_network_state(id, "STARTED")
    end

    def stop_network(credentials, id)
      check_credentials(credentials)
      update_network_state(id, "STOPPED")
    end

    def suspend_network(credentials, id)
      check_credentials(credentials)
      update_network_state(id, "SUSPENDED")
    end

    def network_configurations(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_configs = @client.load_all_cimi(:network_configuration).map{|net_config| CIMI::Model::NetworkConfiguration.from_json(net_config)}
        network_configs.map{|net_config|convert_cimi_mock_urls(:network_configuration, net_config, opts[:env])}.flatten
      else
        network_config = CIMI::Model::NetworkConfiguration.from_json(@client.load_cimi(:network_configuration, opts[:id]))
        convert_cimi_mock_urls(:network_configuration, network_config, opts[:env])
      end
    end

    def network_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_templates = @client.load_all_cimi(:network_template).map{|net_templ| CIMI::Model::NetworkTemplate.from_json(net_templ)}
        network_templates.map{|net_templ|convert_cimi_mock_urls(:network_template, net_templ, opts[:env])}.flatten
      else
        network_template = CIMI::Model::NetworkTemplate.from_json(@client.load_cimi(:network_template, opts[:id]))
        convert_cimi_mock_urls(:network_template, network_template, opts[:env])
      end
    end

    def routing_groups(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        routing_groups = @client.load_all_cimi(:routing_group).map{|rg| CIMI::Model::RoutingGroup.from_json(rg)}
        routing_groups.map{|rg|convert_cimi_mock_urls(:routing_group, rg, opts[:env])}.flatten
      else
        routing_group = CIMI::Model::RoutingGroup.from_json(@client.load_cimi(:routing_group, opts[:id]))
        convert_cimi_mock_urls(:routing_group, routing_group, opts[:env])
      end
    end

    def routing_group_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        routing_group_templates = @client.load_all_cimi(:routing_group_template).map{|rg_templ| CIMI::Model::RoutingGroupTemplate.from_json(rg_templ)}
        routing_group_templates.map{|rg_templ|convert_cimi_mock_urls(:routing_group_template, rg_templ, opts[:env])}.flatten
      else
        routing_group_template = CIMI::Model::RoutingGroupTemplate.from_json(@client.load_cimi(:routing_group_template, opts[:id]))
        convert_cimi_mock_urls(:routing_group_template, routing_group_template, opts[:env])
      end
    end

    def vsps(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        vsps = @client.load_all_cimi(:vsp).map{|vsp| CIMI::Model::VSP.from_json(vsp)}
        vsps.map{|vsp|convert_cimi_mock_urls(:vsp, vsp, opts[:env])}.flatten
      else
        vsp = CIMI::Model::VSP.from_json(@client.load_cimi(:vsp, opts[:id]))
        convert_cimi_mock_urls(:vsp, vsp, opts[:env])
      end
    end

    def vsp_configurations(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        vsp_configurations = @client.load_all_cimi(:vsp_configuration).map{|vsp_config| CIMI::Model::VSPConfiguration.from_json(vsp_config)}
        vsp_configurations.map{|vsp_config|convert_cimi_mock_urls(:vsp_configuration, vsp_config, opts[:env])}.flatten
      else
        vsp_configuration = CIMI::Model::VSPConfiguration.from_json(@client.load_cimi(:vsp_configuration, opts[:id]))
        convert_cimi_mock_urls(:vsp_configuration, vsp_configuration, opts[:env])
      end
    end

    def vsp_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        vsp_templates = @client.load_all_cimi(:vsp_template).map{|vsp_templ| CIMI::Model::VSPTemplate.from_json(vsp_templ)}
        vsp_templates.map{|vsp_templ|convert_cimi_mock_urls(:vsp_template, vsp_templ, opts[:env])}.flatten
      else
        vsp_template = CIMI::Model::VSPTemplate.from_json(@client.load_cimi(:vsp_template, opts[:id]))
        convert_cimi_mock_urls(:vsp_template, vsp_template, opts[:env])
      end
    end

    def addresses(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        addresses = @client.load_all_cimi(:address).map{|addr| CIMI::Model::Address.from_json(addr)}
        addresses.map{|addr|convert_cimi_mock_urls(:address, addr, opts[:env])}.flatten
      else
        address = CIMI::Model::Address.from_json(@client.load_cimi(:address, opts[:id]))
        convert_cimi_mock_urls(:address, address, opts[:env])
      end
    end

    def create_address(credentials, opts={})
      check_credentials(credentials)
      id = "#{opts[:env].send("addresses_url")}/#{opts[:name]}"
      addr_hash = { "id"    => id,
                    "name"  => opts[:name],
                    "description" => opts[:description],
                    "hostName" => opts[:address_template].hostname,
                    "allocation" => opts[:address_template].allocation,
                    "defaultGateway" => opts[:address_template].default_gateway,
                    "dns" => opts[:address_template].dns,
                    "macAddress" => opts[:address_template].mac_address,
                    "protocol" => opts[:address_template].protocol,
                    "mask" => opts[:address_template].mask,
                    "network" => {"href" => opts[:address_template].network.href},
                    "operations" => [{"rel"=>"edit", "href"=> id},
                                     {"rel"=>"delete", "href"=> id}]
                   }
      address = CIMI::Model::Address.from_json(JSON.generate(addr_hash))
      @client.store_cimi(:address, address)
      address
    end

    def delete_address(credentials, id)
      check_credentials(credentials)
      @client.destroy_cimi(:address, id)
    end

    def address_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        address_templates = @client.load_all_cimi(:address_template).map{|addr_templ| CIMI::Model::AddressTemplate.from_json(addr_templ)}
        address_templates.map{|addr_templ|convert_cimi_mock_urls(:address_template, addr_templ, opts[:env])}.flatten
      else
        address_template = CIMI::Model::AddressTemplate.from_json(@client.load_cimi(:address_template, opts[:id]))
        convert_cimi_mock_urls(:address_template, address_template, opts[:env])
      end
    end

    private

    def convert_cimi_mock_urls(model_name, cimi_object, context)
      cimi_object.attribute_values.each do |k,v|
        if ( v.is_a?(Struct) || ( v.is_a?(Array) && v.first.is_a?(Struct)))
          case v
            when Array
              v.each do |item|
                convert_struct_urls(item, k.to_s.singularize.to_sym, context)
              end
            else
              convert_struct_urls(v, k, context)
            end
        end
      end
      object_url = context.send(:"#{model_name}_url", cimi_object.name)
      cimi_object.id=object_url
      cimi_object.operations.each{|op| op.href=object_url  }
      cimi_object
    end

    def convert_struct_urls(struct, cimi_name, context)
      return unless (struct.respond_to?(:href) && (not struct.href.nil?) && (not cimi_name == :operation ))
      obj_name = struct.href.split("/").last
      if cimi_name.to_s.end_with?("config")
        struct.href = context.send(:"#{cimi_name}uration_url", obj_name)
      else
        struct.href = context.send(:"#{cimi_name}_url", obj_name)
      end
    end

    def update_network_state(id, new_state)
      network = CIMI::Model::Network.from_json(@client.load_cimi(:network, id))
      network.state = new_state
      @client.store_cimi(:network, network)
      network
    end

  end

end
