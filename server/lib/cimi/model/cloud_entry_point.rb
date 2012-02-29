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

class CIMI::Model::CloudEntryPoint < CIMI::Model::Base

  array :entity_metadata do
    scalar :href
  end

  def self.create(context)
    self.new(entities(context).merge({
      :name => context.driver.name,
      :description => "Cloud Entry Point for the Deltacloud #{context.driver.name} driver",
      :id => context.cloudEntryPoint_url,
      :created => Time.now,
      :entity_metadata => EntityMetadata.all_uri(context)
    }))
  end

  # Return an Hash of the CIMI root entities used in CloudEntryPoint
  def self.entities(context)
    CIMI::Model.root_entities.inject({}) do |result, entity|
      if context.respond_to? :"#{entity.underscore}_url"
        result[entity.underscore] = { :href => context.send(:"#{entity.underscore}_url") }
      end
      result
    end
  end

  private

  def self.href_defined?(entity)
    true if schema.attribute_names.include? entity.underscore
  end

end
