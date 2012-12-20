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


class CIMI::Model::ResourceMetadata < CIMI::Model::Base

  acts_as_root_entity

  text :name

  text :type_uri

  array :attributes do
    scalar :name
    scalar :namespace
    scalar :type
    scalar :required
    array :constraints do
      text :value
    end
  end

  array :capabilities do
    scalar :name
    scalar :uri
    scalar :description
    scalar :value, :text => :direct
  end


  array :actions do
    scalar :name
    scalar :uri
    scalar :description
    scalar :method
    scalar :input_message
    scalar :output_message
  end

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    if id == :all
      resource_metadata = []
      CIMI::Model.root_entities.each do |resource_class|
        meta = resource_metadata_for(resource_class, context)
        resource_metadata << meta unless none_defined(meta)
      end
      return resource_metadata
    else
      resource_class = CIMI::Model.const_get("#{id.camelize}")
      resource_metadata_for(resource_class, context)
    end
  end

  def self.resource_metadata_for(resource_class, context)
    attributes = rm_attributes_for(resource_class, context)
    capabilities = rm_capabilities_for(resource_class, context)
    actions = rm_actions_for(resource_class, context)
    cimi_resource = resource_class.name.split("::").last
    self.new({ :id => context.resource_metadata_url(cimi_resource.underscore),
              :name => cimi_resource,
              :type_uri => resource_class.resource_uri,
              :attributes => attributes,
              :capabilities => capabilities,
              :actions => actions
    })
  end

  private

  def self.rm_attributes_for(resource_class, context)
    []
  end

  def self.rm_capabilities_for(resource_class,context)
    cimi_object = resource_class.name.split("::").last.underscore.pluralize.to_sym
    capabilities = (context.driver.class.features[cimi_object] || []).inject([]) do |res, cur|
      feat = CIMI::FakeCollection.feature(cur)
      values = (context.driver.class.constraints[cimi_object][feat.name][:values] || []).inject([]) do |vals, val|
        vals <<  val
        vals
      end
      res << {:name => feat.name.to_s.camelize,
       :uri => CMWG_NAMESPACE+"/capability/#{cimi_object.to_s.camelize.singularize}/#{feat.name.to_s.camelize}",
       :description => feat.description,
       :value => values.join(",") }
      res
    end
#cimi_resource.underscore.pluralize.to_sym
  end

  def self.rm_actions_for(resource_class, context)
    []
  end

  def self.none_defined(metadata)
    return true if metadata.capabilities.empty? && metadata.capabilities.empty? && metadata.attributes.empty?
    return false
  end

end
