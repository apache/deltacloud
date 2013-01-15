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

class CIMI::Model::VolumeConfiguration < CIMI::Model::Base

  acts_as_root_entity :as => "volumeConfigs"

  text :format

  text :capacity

  array :operations do
    scalar :rel, :href
  end

  def self.create_from_json(body, context)
    json = JSON.parse(body)
    new_config = current_db.add_volume_configuration(
      :name => json['name'],
      :description => json['description'],
      :format => json['format'],
      :capacity => json['capacity'],
      :ent_properties => json['properties'].to_json,
    )
    from_db(new_config, context)
  end

  def self.create_from_xml(body, context)
    xml = XmlSimple.xml_in(body)
    xml['property'] ||= []
    new_config = current_db.add_volume_configuration(
      :name => xml['name'].first,
      :description => xml['description'].first,
      :format => xml['format'].first,
      :capacity => xml['capacity'].first,
      :ent_properties => JSON::dump(xml['property'].inject({}) { |r, p| r[p['key']]=p['content']; r }),
    )
    from_db(new_config, context)
  end

  def self.delete!(id, context)
    current_db.volume_configurations.first(:id => id).destroy
  end

  def self.find(id, context)
    if id==:all
      if context.driver.respond_to? :volume_configurations
        context.driver.volume_configurations(context.credentials, {:env=>context})
      else
        current_db.volume_configurations.map { |t| from_db(t, context) }
      end
    else
      if context.driver.respond_to? :volume_configuration
        context.driver.volume_configuration(context.credentials, id, :env=>context)
      else
        config = current_db.volume_configurations_dataset.first(:id => id)
        raise CIMI::Model::NotFound unless config
        from_db(config, context)
      end
    end
  end

  private

  def self.from_db(model, context)
    self.new(
      :id => context.volume_configuration_url(model.id),
      :name => model.name,
      :description => model.description,
      :format => model.format,
      :capacity => context.to_kibibyte(model.capacity, "GB"),
      :property => JSON::parse(model.ent_properties),
      :operations => [
        { :href => context.destroy_volume_configuration_url(model.id), :rel => 'http://schemas.dmtf.org/cimi/1/action/delete' }
      ]
    )
  end

end
