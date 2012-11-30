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

class CIMI::Model::MachineTemplate < CIMI::Model::Base

  acts_as_root_entity

  href :machine_config
  href :machine_image
  href :credential

  array :volumes do
    scalar :href
    scalar :protocol
    scalar :attachment_point
  end

  array :volume_templates do
    scalar :href, :attachment_point, :protocol
  end

  array :network_interfaces do
    href :vsp
    text :hostname, :mac_address, :state, :protocol, :allocation
    text :address, :default_gateway, :dns, :max_transmission_unit
  end

  array :operations do
    scalar :rel, :href
  end

  class << self
    def find(id, context)
      if id == :all
        context.current_db.machine_templates.all.map { |t| from_db(t, context) }
      else
        template = context.current_db.machine_templates.first(:id => id)
        raise CIMI::Model::NotFound unless template
        from_db(template, context)
      end
    end

    def create_from_json(body, context)
      json = JSON.parse(body)
      new_template = context.current_db.machine_templates.new(
        :name => json['name'],
        :description => json['description'],
        :machine_config => json['machineConfig']['href'],
        :machine_image => json['machineImage']['href'],
        :ent_properties => json['properties'].to_json,
        :be_kind => 'machine_template',
        :be_id => ''
      )
      new_template.save!
      from_db(new_template, context)
    end

    def create_from_xml(body, context)
      xml = XmlSimple.xml_in(body)
      new_template = context.current_db.machine_templates.new(
        :name => xml['name'].first,
        :description => xml['description'].first,
        :machine_config => xml['machineConfig'].first['href'],
        :machine_image => xml['machineImage'].first['href'],
        :ent_properties => xml['property'].inject({}) { |r, p| r[p['name']]=p['content']; r },
        :be_kind => 'machine_template',
        :be_id => ''
      )
      new_template.save!
      from_db(new_template, context)
    end

    def delete!(id, context)
      context.current_db.machine_templates.first(:id => id).destroy
    end

    private

    def from_db(model, context)
      self.new(
        :id => context.machine_template_url(model.id),
        :name => model.name,
        :description => model.description,
        :machine_config => { :href => model.machine_config },
        :machine_image => { :href => model.machine_image },
        :property => model.ent_properties,
        :operations => [
          { :href => context.destroy_machine_template_url(model.id), :rel => 'http://schemas.dmtf.org/cimi/1/action/delete' }
        ]
      )
    end
  end

end
