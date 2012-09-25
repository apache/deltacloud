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

    def forwarding_groups(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        forwarding_groups = @client.load_all_cimi(:forwarding_group).map{|fg| CIMI::Model::ForwardingGroup.from_json(fg)}
        forwarding_groups.map{|fg|convert_cimi_mock_urls(:forwarding_group, fg, opts[:env])}.flatten
      else
        forwarding_group = CIMI::Model::ForwardingGroup.from_json(@client.load_cimi(:forwarding_group, opts[:id]))
        convert_cimi_mock_urls(:forwarding_group, forwarding_group, opts[:env])
      end
    end

    def forwarding_group_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        forwarding_group_templates = @client.load_all_cimi(:forwarding_group_template).map{|fg_templ| CIMI::Model::ForwardingGroupTemplate.from_json(fg_templ)}
        forwarding_group_templates.map{|fg_templ|convert_cimi_mock_urls(:forwarding_group_template, fg_templ, opts[:env])}.flatten
      else
        forwarding_group_template = CIMI::Model::ForwardingGroupTemplate.from_json(@client.load_cimi(:forwarding_group_template, opts[:id]))
        convert_cimi_mock_urls(:forwarding_group_template, forwarding_group_template, opts[:env])
      end
    end

    def network_ports(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        ports = @client.load_all_cimi(:network_port).map{|net_port| CIMI::Model::NetworkPort.from_json(net_port)}
        ports.map{|net_port|convert_cimi_mock_urls(:network_port, net_port, opts[:env])}.flatten
      else
        port = CIMI::Model::NetworkPort.from_json(@client.load_cimi(:network_port, opts[:id]))
        convert_cimi_mock_urls(:network_port, port, opts[:env])
      end
    end

    def network_port_configurations(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_port_configurations = @client.load_all_cimi(:network_port_configuration).map{|network_port_config| CIMI::Model::NetworkPortConfiguration.from_json(network_port_config)}
        network_port_configurations.map{|network_port_config|convert_cimi_mock_urls(:network_port_configuration, network_port_config, opts[:env])}.flatten
      else
        network_port_configuration = CIMI::Model::NetworkPortConfiguration.from_json(@client.load_cimi(:network_port_configuration, opts[:id]))
        convert_cimi_mock_urls(:network_port_configuration, network_port_configuration, opts[:env])
      end
    end

    def network_port_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_port_templates = @client.load_all_cimi(:network_port_template).map{|net_port_templ| CIMI::Model::NetworkPortTemplate.from_json(net_port_templ)}
        network_port_templates.map{|net_port_templ|convert_cimi_mock_urls(:network_port_template, net_port_templ, opts[:env])}.flatten
      else
        network_port_template = CIMI::Model::NetworkPortTemplate.from_json(@client.load_cimi(:network_port_template, opts[:id]))
        convert_cimi_mock_urls(:network_port_template, network_port_template, opts[:env])
      end
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
              opts = nil
              if is_subcollection?(v, cimi_object.id)
                opts = {:parent_model_name => model_name, :parent_item_name => cimi_object.name}
              end
              convert_struct_urls(v, k, context, opts)
            end
        end
      end
      object_url = context.send(:"#{model_name}_url", cimi_object.name)
      cimi_object.id=object_url
      cimi_object.operations.each{|op| op.href=object_url  }
      cimi_object
    end

    def is_subcollection?(struct, cimi_object_id)
      return false if struct.href.nil?
      struct.href.include?(cimi_object_id)
    end

    def convert_struct_urls(struct, cimi_name, context, opts = nil)
      return unless (struct.respond_to?(:href) && (not struct.href.nil?) && (not cimi_name == :operation ))
      if opts
        struct.href = context.send(:"#{opts[:parent_model_name]}_url", opts[:parent_item_name]) + "/#{cimi_name}"
      else
        obj_name = struct.href.split("/").last
        if cimi_name.to_s.end_with?("config")
          struct.href = context.send(:"#{cimi_name}uration_url", obj_name)
        else
          struct.href = context.send(:"#{cimi_name}_url", obj_name)
        end
      end
    end

  end

end
