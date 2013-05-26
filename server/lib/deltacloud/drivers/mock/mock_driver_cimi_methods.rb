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

    def systems(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        systems = @client.load_all_cimi(:system).map{|sys| CIMI::Model::System.from_json(sys)}
      else
        begin
          systems = [CIMI::Model::System.from_json(@client.load_cimi(:system, opts[:id]))]
        rescue Errno::ENOENT
          return []
        end
      end
      systems.map{|sys| convert_urls(sys, opts[:env])}.flatten
      systems
    end

    def create_system(credentials, opts={})
      check_credentials(credentials)
      create_system_components_for(opts[:name], opts[:system_template].component_descriptors, opts[:env])
      id = "#{opts[:env].send("systems_url")}/#{opts[:name]}"
      sys_hsh = { "id"=> id,
                  "name" => opts[:name],
                  "description" => opts[:description],
                  "created" => Time.now,
                  "state" => "STARTED",
                  "operations" => [{"rel"=>"http://schemas.dmtf.org/cimi/1/action/stop",  "href"=> "#{id}/stop"},
                                   {"rel"=>"edit", "href"=> id},
                                   {"rel"=>"delete", "href"=> id}]}
      system = CIMI::Model::System.from_json(JSON.generate(sys_hsh))
      @client.store_cimi(:system, system)
      system
    end

    def create_system_components_for(system_id, component_descriptors, context)
      component_descriptors.each do |cd|
        cd_type = cd.type.split("/").last
        model = CIMI::Model.const_get("#{cd_type}Create").new
        #assign the template from the component descriptor
        model.send("#{cd_type.underscore}_template=".to_sym, cd.send("#{cd_type.underscore}_template".to_sym))
        #also the name, description from the component descriptor for the new resource:
        model.send(:name=, cd.name)
        model.send(:description=, cd.description)
        resource = CIMI::Service.const_get("#{cd_type}Create").new(context, :model=>model)
        #create quantity number of resources, obeying naming rules
        if cd.quantity && cd.quantity > 1
          cd.quantity.times do |t|
            resource.model.send(:name=, "#{cd.name}#{t+1}")
            created_sys_comp = resource.create.model
            store_created_system_component(created_sys_comp, cd_type, system_id, context)
          end
        else
          created_sys_comp = resource.create.model
          store_created_system_component(created_sys_comp, cd_type, system_id, context)
        end
      end
    end

    def store_created_system_component(component, type, system_id, context)
      seq_id = generate_system_component_id(type.underscore)
      id = "#{context.send("system_url")}/#{system_id}/#{type.pluralize.underscore}/#{seq_id}"
      system_component_hash = { :id => id,
                                :name =>component.name,
                                :description =>component.description,
                                :created => Time.now,
                                "#{type.underscore}".to_sym => {:href => component.id},
                                :operations=> [{"rel"=>"edit", "href"=> id},
                                               {"rel"=>"delete", "href"=> id}]
                               }
      system_component = CIMI::Model.const_get("System#{type}").from_json(JSON.generate(system_component_hash))
      @client.store_cimi("system_#{type.underscore}".to_sym, system_component, seq_id)
    end

    def generate_system_component_id(type)
      ids = @client.cimi_members("system_#{type}".to_sym)
      count, next_id = 1, ''
      loop do
        break unless ids.include?(next_id = "sys_#{type}_#{count}")
        count = count + 1
      end
      next_id
    end

    def destroy_system(credentials, id)
      check_credentials(credentials)
      #retrieve the system_machines to delete them
      sys_machines = system_machines(credentials, {:system_id => id})
      sys_machines.each do |mach|
        inst_id = mach.machine.href.split("/").last
        @client.destroy(:instances, inst_id)
        mach_id = mach.id.split("/").last
        @client.destroy_cimi(:system_machine, mach_id)
      end
      @client.destroy_cimi(:system, id)
    end

    def start_system(credentials, id)
      check_credentials(credentials)
      sys_machines = system_machines(credentials, {:system_id => id})
      sys_machines.each do |mach|
        inst_id = mach.machine.href.split("/").last
        update_instance_state(credentials, inst_id , "RUNNING") #deltacloud instance, not machine
      end
      #retrieve system machines:
      update_object_state(id, "System", "STARTED")
    end

    def stop_system(credentials, id)
      check_credentials(credentials)
      sys_machines = system_machines(credentials, {:system_id => id})
      sys_machines.each do |mach|
        inst_id = mach.machine.href.split("/").last
        update_instance_state(credentials, inst_id , "STOPPED")
      end
      update_object_state(id, "System", "STOPPED")
    end

    def system_machines(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        all_machines = @client.load_all_cimi(:system_machine).map{|mach| CIMI::Model::SystemMachine.from_json(mach)}
        #grab only ones for system_id:
        machines = all_machines.inject([]){|res,cur| res << cur if cur.id =~ /^.*\/systems\/#{opts[:system_id]}\/machines/  ;res}
      else
        begin
          machines = [CIMI::Model::SystemMachine.from_json(@client.load_cimi(:system_machine, opts[:id]))]
        rescue Errno::ENOENT
          return []
        end
      end
      machines.map{|m|convert_urls(m, opts[:env])}.flatten
    end

    def system_volumes(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        all_volumes = @client.load_all_cimi(:system_volume).map{|vol| CIMI::Model::SystemVolume.from_json(vol)}
        volumes = all_volumes.inject([]){|res,cur| res << cur if cur.id =~ /^.*\/systems\/#{opts[:system_id]}\/volumes/  ;res}
      else
        begin
          volumes = [CIMI::Model::SystemVolume.from_json(@client.load_cimi(:system_volume, opts[:id]))]
        rescue Errno::ENOENT
          return []
        end
      end
      volumes.map{|vol|convert_urls(vol, opts[:env])}.flatten
    end

    def system_networks(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        networks = @client.load_all_cimi(:system_network).map{|net| CIMI::Model::SystemNetwork.from_json(net)}
      else
        begin
          networks = [CIMI::Model::SystemNetwork.from_json(@client.load_cimi(:system_network, opts[:id]))]
        rescue Errno::ENOENT
          return []
        end
      end
      networks.map{|n|convert_urls(n, opts[:env])}.flatten
    end

    def system_addresses(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        addresses = @client.load_all_cimi(:system_address).map{|a| CIMI::Model::SystemAddress.from_json(a)}
      else
        begin
          addresses = [CIMI::Model::SystemVolume.from_json(@client.load_cimi(:system_address, opts[:id]))]
        rescue Errno::ENOENT
          return []
        end
      end
      addresses.map{|a|convert_urls(a, opts[:env])}.flatten
    end

    def system_forwarding_groups(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        groups = @client.load_all_cimi(:system_forwarding_group).map{|group| CIMI::Model::SystemForwardingGroup.from_json(group)}
      else
        begin
          groups = [CIMI::Model::SystemForwardingGroup.from_json(@client.load_cimi(:system_forwarding_group, opts[:id]))]
        rescue Errno::ENOENT
          return []
        end
      end
      groups.map{|g|convert_urls(g, opts[:env])}.flatten
    end

    def system_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        system_templates = @client.load_all_cimi(:system_template).map{|sys_templ| CIMI::Model::SystemTemplate.from_json(sys_templ)}
      else
        begin
          system_templates = [CIMI::Model::SystemTemplate.from_json(@client.load_cimi(:system_template, opts[:id]))]
        rescue Errno::ENOENT
          return []
        end
      end
      system_templates.map{|sys_templ| convert_urls(sys_templ, opts[:env])}.flatten
    end

    def network_configurations(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_configs = @client.load_all_cimi(:network_configuration).map{|net_config| CIMI::Model::NetworkConfiguration.from_json(net_config)}
        network_configs.map{|net_config| convert_urls(net_config, opts[:env])}.flatten
      else
        network_config = CIMI::Model::NetworkConfiguration.from_json(@client.load_cimi(:network_configuration, opts[:id]))
        convert_urls(network_config, opts[:env])
      end
    end

    def network_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_templates = @client.load_all_cimi(:network_template).map{|net_templ| CIMI::Model::NetworkTemplate.from_json(net_templ)}
        network_templates.map{|net_templ| convert_urls(net_templ, opts[:env])}.flatten
      else
        network_template = CIMI::Model::NetworkTemplate.from_json(@client.load_cimi(:network_template, opts[:id]))
        convert_urls(network_template, opts[:env])
      end
    end

    def forwarding_group_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        forwarding_group_templates = @client.load_all_cimi(:forwarding_group_template).map{|fg_templ| CIMI::Model::ForwardingGroupTemplate.from_json(fg_templ)}
        forwarding_group_templates.map{|fg_templ| convert_urls(fg_templ, opts[:env])}.flatten
      else
        forwarding_group_template = CIMI::Model::ForwardingGroupTemplate.from_json(@client.load_cimi(:forwarding_group_template, opts[:id]))
        convert_urls(forwarding_group_template, opts[:env])
      end
    end

    def network_ports(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        ports = @client.load_all_cimi(:network_port).map{|net_port| CIMI::Model::NetworkPort.from_json(net_port)}
        ports.map{|net_port| convert_urls(net_port, opts[:env])}.flatten
      else
        port = CIMI::Model::NetworkPort.from_json(@client.load_cimi(:network_port, opts[:id]))
        convert_urls(port, opts[:env])
      end
    end

    def network_port_configurations(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_port_configurations = @client.load_all_cimi(:network_port_configuration).map{|network_port_config| CIMI::Model::NetworkPortConfiguration.from_json(network_port_config)}
        network_port_configurations.map{|network_port_config| convert_urls(network_port_config, opts[:env])}.flatten
      else
        network_port_configuration = CIMI::Model::NetworkPortConfiguration.from_json(@client.load_cimi(:network_port_configuration, opts[:id]))
        convert_urls(network_port_configuration, opts[:env])
      end
    end

    def network_port_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        network_port_templates = @client.load_all_cimi(:network_port_template).map{|net_port_templ| CIMI::Model::NetworkPortTemplate.from_json(net_port_templ)}
        network_port_templates.map{|net_port_templ| convert_urls(net_port_templ, opts[:env])}.flatten
      else
        network_port_template = CIMI::Model::NetworkPortTemplate.from_json(@client.load_cimi(:network_port_template, opts[:id]))
        convert_urls(network_port_template, opts[:env])
      end
    end

    def address_templates(credentials, opts={})
      check_credentials(credentials)
      if opts[:id].nil?
        address_templates = @client.load_all_cimi(:address_template).map{|addr_templ| CIMI::Model::AddressTemplate.from_json(addr_templ)}
        address_templates.map{|addr_templ| convert_urls(addr_templ, opts[:env])}.flatten
      else
        address_template = CIMI::Model::AddressTemplate.from_json(@client.load_cimi(:address_template, opts[:id]))
        convert_urls(address_template, opts[:env])
      end
    end

    private

    # Convert all attributes that have values of the form
    #   http://cimi.example.org/COLL/ID
    #   or
    #   http://cimi.example.org/COLL/ID/SUBCOLL/ENT_ID
    def convert_urls(val, context)
      if val.nil? || val.is_a?(Fixnum)
        # Nothing to do
      elsif val.is_a?(Struct)
        val.members.each { |m| val[m] = convert_urls(val[m], context) }
      elsif val.is_a?(Hash)
        val.keys.each { |m| val[m] = convert_urls(val[m], context) }
      elsif val.is_a?(Array)
        val.each_index { |i| val[i] = convert_urls(val[i], context) }
      elsif val.is_a?(String)
        val = rewrite_url(val, context)
      elsif val.is_a?(CIMI::Model::Resource)
        val.attribute_values.each do |k, v|
          val[k] = convert_urls(val[k], context)
        end
      else
        # Need to add a branch for val.class
        raise "Whoa ! #{val.inspect}"
      end
      val
    end

    # Rewrite URL assuming it points at a valid resource; if that's not
    # possible, return +s+
    #
    # URLs that should be rewritten need to be in the form
    #   http://cimi.example.org/COLLECTION/ID
    #   or
    #   http://cimi.example.org/COLLECTION/SYSTEM_ID/SUBCOLLECTION/ENT_ID
    def rewrite_url(s, context)
      begin
        u = URI.parse(s)
      rescue URI::InvalidURIError
        return s
      end
      return s unless u.scheme == 'http' && u.host == 'cimi.example.org'
      _, coll, id, sub_coll, sub_id = u.path.split("/")
      method = sub_coll ? "#{coll.singularize}_#{sub_coll.singularize}_url"
                        : "#{coll.singularize}_url"
      if context.respond_to?(method)
        sub_coll ? context.send(method, :id => id, :ent_id => sub_id)
                 : context.send(method, id)
      else
        s
      end
    end

    def update_object_state(id, object, new_state)
      klass = CIMI::Model.const_get("#{object}")
      symbol = object.to_s.downcase.singularize.intern
      obj = klass.from_json(@client.load_cimi(symbol, id))
      obj.state = new_state
      @client.store_cimi(symbol, obj)
      obj
    end

  end

end
