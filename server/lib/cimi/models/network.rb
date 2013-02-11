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

  acts_as_root_entity

  text :state

  text :network_type

  text :mtu

  text :class_of_service

  collection :network_ports, :class => CIMI::Model::NetworkPort

  href :forwarding_group

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
    if context.expand? :networkPorts
      networks.each do |network|
        network.network_ports = CIMI::Model::NetworkPort.collection_for_network(network.id, context)
      end
    end
    networks
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

end
