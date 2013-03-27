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

class CIMI::Service::CloudEntryPoint < CIMI::Service::Base

  metadata :driver, :type => 'text'
  metadata :provider, :type => 'text'

  def self.create(context)
    self.new(context, :values => entities(context).merge({
      :name => context.driver.name,
      :description => "Cloud Entry Point for the Deltacloud #{context.driver.name} driver",
      :driver => context.driver.name,
      :provider => context.current_provider,
      :id => context.cloudEntryPoint_url,
      :base_uri => context.base_uri + "/",
      :created => Time.now.xmlschema
    }))
  end

  # Return an Hash of the CIMI root entities used in CloudEntryPoint
  def self.entities(context)
    CIMI::Collections.modules(:cimi).inject({}) do |supported_entities, m|
      m.collections.each do |c|
        if c.operation(:index).nil?
          warn "#{c} does not have :index operation."
          next
        end
        index_operation_capability = c.operation(:index).required_capability
        next if m.settings.respond_to?(:capability) and !m.settings.capability(index_operation_capability)
        supported_entities[c.collection_name.to_s] = { :href => context.send(:"#{c.collection_name}_url") }
      end
      supported_entities
    end
  end

  def entities
    @attribute_values.clone.delete_if { |key, value| !value.respond_to? :href }
  end

end
