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

class CIMI::Model::AddressTemplate < CIMI::Model::Base

  acts_as_root_entity

  text :ip

  text :hostname

  text :allocation

  text :default_gateway

  text :dns

  text :protocol

  text :mask

  href :network

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    if id==:all
      if context.driver.respond_to? :address_templates
        context.driver.address_templates(context.credentials, {:env=>context})
      else
        current_db.address_teplates.map { |t| from_db(t, context) }
      end
    else
      if context.driver.respond_to? :address_template
        context.driver.address_template(context.credentials, id, :env=>context)
      else
        template = current_db.address_templates_dataset.first(:id => id)
        raise CIMI::Model::NotFound unless template
        from_db(template, context)
      end
    end
  end

  def self.create_from_json(body, context)
    json = JSON.parse(body)
    new_template = current_db.add_address_template(
      :name => json['name'],
      :description => json['description'],
      :hostname => json['hostname'],
      :ip => json['ip'],
      :allocation => json['allocation'],
      :default_gateway => json['default_gateway'],
      :dns => json['dns'],
      :protocol => json['protocol'],
      :mask => json['mask'],
      :ent_properties => json['properties'].to_json,
    )
    from_db(new_template, context)
  end

  def self.create_from_xml(body, context)
    xml = XmlSimple.xml_in(body)
    xml['property'] ||= []
    new_template = current_db.add_address_template(
      :name => xml['name'].first,
      :description => xml['description'].first,
      :ip => xml['ip'].first,
      :hostname => xml['hostname'].first,
      :allocation => xml['allocation'].first,
      :default_gateway => xml['default_gateway'].first,
      :dns => xml['dns'].first,
      :protocol => xml['protocol'].nil? ? nil : xml['protocol'].first,
      :mask => xml['mask'].first,
      :ent_properties => JSON::dump(xml['property'].inject({}) { |r, p| r[p['key']]=p['content']; r }),
    )
    from_db(new_template, context)
  end

  def self.delete!(id, context)
    current_db.address_templates.first(:id => id).destroy
  end

  private

  def self.from_db(model, context)
    self.new(
      :id => context.address_template_url(model.id),
      :name => model.name,
      :description => model.description,
      :ip => model.ip,
      :hostname => model.hostname,
      :allocation => model.allocation,
      :default_gateway => model.default_gateway,
      :dns => model.dns,
      :protocol => model.protocol,
      :mask => model.mask,
      :property => JSON::parse(model.ent_properties),
      :operations => [
        { :href => context.destroy_address_template_url(model.id), :rel => 'http://schemas.dmtf.org/cimi/1/action/delete' }
      ]
    )
  end

end
