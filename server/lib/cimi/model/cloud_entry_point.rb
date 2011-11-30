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

  def self.create(context)
    root_entities = CIMI::Model.root_entities.inject({}) do |result, entity|
      send(:href, entity.underscore) if not href_defined?(entity)
      if context.respond_to? :"#{entity.underscore}_url"
        result[entity.underscore] = { :href => context.send(:"#{entity.underscore}_url") }
      end
      result
    end
    root_entities.merge!({
      :name => context.driver.name,
      :description => "Cloud Entry Point for the Deltacloud #{context.driver.name} driver",
      :uri => context.cloudEntryPoint_url,
      :created => Time.now
    })
    self.new(root_entities)
  end

  private

  def self.href_defined?(entity)
    true if schema.attribute_names.include? entity.underscore
  end

end
