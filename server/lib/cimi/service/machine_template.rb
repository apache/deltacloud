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

class CIMI::Service::MachineTemplate < CIMI::Service::Base

  metadata :realm, :constraints => lambda { |c| c.driver.realms(c.credentials).map { |r| r.id }}

  class << self
    def find(id, context)
      if id == :all
        current_db.machine_templates.map { |t| from_db(t, context) }
      else
        template = current_db.machine_templates_dataset.first(:id => id)
        raise CIMI::Model::NotFound unless template
        from_db(template, context)
      end
    end

    def delete!(id, context)
      current_db.machine_templates.first(:id => id).destroy
    end

    def from_db(model, context)
      self.new(context, :values => {
        :id => context.machine_template_url(model.id),
        :name => model.name,
        :description => model.description,
        :machine_config => { :href => model.machine_config },
        :machine_image => { :href => model.machine_image },
        :realm => model.realm,
        :property => (model.ent_properties ? JSON::parse(model.ent_properties) :  nil),
        :created => Time.parse(model.created_at.to_s).xmlschema,
        :operations => [
          {
            :href => context.destroy_machine_template_url(model.id),
            :rel => 'http://schemas.dmtf.org/cimi/1/action/delete'
          }
        ]
      })
    end
  end

  protected
  def attributes_to_copy
    super + [ :machine_config, :machine_image ]
  end
end
