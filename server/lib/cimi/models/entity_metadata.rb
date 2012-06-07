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


class CIMI::Model::EntityMetadata < CIMI::Model::Base

  text :type_uri

  array :attributes do
    scalar :name
    scalar :namespace
    scalar :type
    scalar :required
    scalar :constraints
  end

  array :operations do
    scalar :name
    scalar :uri
    scalar :description
    scalar :method
    scalar :input_message
    scalar :output_message
  end

  def self.find(id, context)
    entity_metadata = []
    if id == :all
      CIMI::Model.root_entities.each do |entity|
        entity_class = CIMI::Model.const_get("#{entity.singularize}")
        entity_metadata << entity_class.create_entity_metadata(context) if entity_class.respond_to?(:create_entity_metadata)
      end
      return entity_metadata
    else
      entity_class = CIMI::Model.const_get("#{id.camelize}")
      if entity_class.respond_to?(:create_entity_metadata)
        entity_class.create_entity_metadata(context)
      end
    end
  end

  def self.metadata_from_deltacloud_features(cimi_entity, dcloud_entity, context)
    deltacloud_features = context.driver.class.features[dcloud_entity]
    metadata_attributes = deltacloud_features.map{|f| attributes_from_feature(f)}
    from_feature(cimi_entity, context, metadata_attributes.flatten!)
  end

  def includes_attribute?(attribute)
    self.attributes.any?{|attr| attr[:name] == attribute}
  end

  private

  def self.attributes_from_feature(feature)
    feature = CIMI::FakeCollection.feature(feature)
    feature.operations.first.params_array.map do |p|
      {
        :name=> p.name,
        :type=> "xs:string",
        :required=> p.required? ? "true" : "false",
        :constraints=> (feature.constraints.empty? ? (feature.description.nil? ? "" : feature.description): feature.constraints)
      }
    end
  end

  def self.from_feature(cimi_entity, context, metadata_attributes)
    self.new(:name => cimi_entity, :uri=>"#{context.entity_metadata_url}/#{cimi_entity.underscore}",
             :type_uri=> context.send("#{cimi_entity.pluralize.underscore}_url"),
             :attributes => metadata_attributes)
  end

end
