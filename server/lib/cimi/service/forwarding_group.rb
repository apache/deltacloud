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

class CIMI::Service::ForwardingGroup < CIMI::Service::Base

  def self.find(id, context)
    if id==:all
      networks = context.driver.networks(context.credentials)
      networks.map { |network| from_network(network, context) }.compact
    else
      network = context.driver.network(context.credentials, :id=>id)
      raise CIMI::Model::NotFound unless network and network.subnets.size > 1
      from_network(network, context)
    end
  end

  def self.delete!(id, context)
    context.driver.destroy_network(context.credentials, id)
  end

  def self.from_network(network, context)
    network_spec = {
      :id               => context.forwarding_group_url(network.id),
      :name             => network.name,
      :description      => network.description || "No description set for Forwarding Group #{network.name}",
      :networks         => network.subnets.collect {|s| {:href=>context.network_url(s)} }
    }
    self.new(context, :values => network_spec) if network.subnets.size > 1
  end

end
