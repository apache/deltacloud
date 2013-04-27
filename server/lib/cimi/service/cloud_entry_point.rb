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

  def initialize(context)
    super(context, :values => {
      :name => context.driver.name,
      :description => "Cloud Entry Point for the Deltacloud #{context.driver.name} driver",
      :driver => context.driver.name,
      :provider => context.current_provider,
      :id => context.cloudEntryPoint_url,
      :base_uri => context.base_uri + "/",
      :created => Time.now.xmlschema
    })
    remove_unsupported_collections!(context)
    expand_collections!(context)
  end

  def remove_unsupported_collections!(context)
    each_collection do |m, c|
      remove_collection(c.collection_name) && next if c.operation(:index).nil?
      remove_collection(c.collection_name) && next if c.collection_name == :cloudEntryPoint
      index_operation_capability = c.operation(:index).required_capability
      if m.settings.respond_to?(:capability) and !m.settings.capability(index_operation_capability)
        remove_collection(c.collection_name)
      end
    end
  end

  def expand_collections!(context)
    each_collection do |m, c|
      if context.expand? c.collection_name.to_s.camelize(:lower).to_sym
        self.model.attribute_values[c.collection_name] = \
          SERVICES[c.collection_name.to_s].list(context)
      end
    end
  end

  def remove_collection(collection_name)
    self.model.attribute_values.delete(collection_name)
  end

  def each_collection(&block)
    CIMI::Collections.modules(:cimi).each do |m|
      m.collections.each do |c|
        yield m,c
      end
    end
  end

end

