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

class CIMI::Service::Network < CIMI::Service::Base

  def self.find(id, context)
    if id==:all
      subnets = context.driver.subnets(context.credentials)
      subnets.map { |subnet| from_subnet(subnet, context) }.compact
    else
      subnet = context.driver.subnet(context.credentials, :id=>id)
      raise CIMI::Model::NotFound unless subnet
      from_subnet(subnet, context)
    end
  end

  def self.delete!(id, context)
    context.driver.destroy_subnet(context.credentials, id)
  end

  def perform(action, &block)
    begin
      op = action.operation
      if context.driver.send(:"#{op}_network", context.credentials, id)
        block.callback :success
      else
        raise "Operation #{action.name} failed to execute on the Network #{id} "
      end
    rescue => e
      block.callback :failure, e.message
    end
  end

  def self.from_subnet(subnet, context)
    network_spec = {
      :id               => context.network_url(subnet.id),
      :name             => subnet.name,
      :description      => subnet.description || "No description set for Network #{subnet.name}",
      :state            => convert_subnet_state(subnet.state),
      :network_type     => subnet.type,
#      :mtu              => subnet.mtu,
#      :class_of_service => subnet.classOfService,
#TODO: only networks with multiple subnets can be mapped to forwarding groups
#      :forwarding_group => context.forwarding_group_url(subnet.network),
      :network_ports    => { :href=>context.network_url(subnet.id)+"/network_ports"}
    }
    network_spec[:operations] = [{ :href => context.send(:destroy_network_url, subnet.id), :rel => "delete" }]
    if context.driver.respond_to? :start_subnet and network_spec[:state] == 'STOPPED'
      network_spec[:operations] << { :href => context.send(:start_network_url, subnet.id), :rel => "http://schemas.dmtf.org/cimi/1/action/start" }
    end
    if context.driver.respond_to? :stop_subnet and network_spec[:state] == 'STARTED'
      network_spec[:operations] << { :href => context.send(:stop_network_url, subnet.id), :rel => "http://schemas.dmtf.org/cimi/1/action/stop" }
    end
    self.new(context, :values => network_spec)
  end

  def self.convert_subnet_state(state)
    case state
      when "UP" then "STARTED"
      when "DOWN" then "STOPPED"
      else state
    end
  end

end
