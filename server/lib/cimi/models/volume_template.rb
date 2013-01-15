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

class CIMI::Model::VolumeTemplate < CIMI::Model::Base

  acts_as_root_entity

  href :volume_config
  href :volume_image

  array :meter_templates do
  end

  href :event_log_template

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    if id==:all
      if context.driver.respond_to? :volume_templates
        context.driver.volume_templates(context.credentials, {:env=>context})
      else
        current_db.volume_templates.map { |t| from_db(t, context) }
      end
    else
      if context.driver.respond_to? :volume_template
        context.driver.volume_template(context.credentials, id, :env=>context)
      else
        template = current_db.volume_templates_dataset.first(:id => id)
        raise CIMI::Model::NotFound unless template
        from_db(template, context)
      end
    end
  end

  def self.create(body, context, type)
    input = (type == :xml)? XmlSimple.xml_in(body, {"ForceArray"=>false,"NormaliseSpace"=>2}) : JSON.parse(body)
    input['property'] ||= []
    vol_image = input['volumeImage']['href'] if input['volumeImage']
    new_template = current_db.add_volume_template(
      :name => input['name'],
      :description => input['description'],
      :volume_config => input['volumeConfig']['href'],
      :volume_image => vol_image,
      :ent_properties => JSON::dump(input['property'].inject({}) { |r, p| r[p['key']]=p['content']; r }),
    )
    from_db(new_template, context)
  end

  def self.delete!(id, context)
    current_db.volume_templates.first(:id => id).destroy
  end

private

  def self.from_db(model, context)
    self.new(
      :id => context.volume_template_url(model.id),
      :name => model.name,
      :description => model.description,
      :volume_config => {:href => model.volume_config},
      :volume_image => {:href => model.volume_image},
      :property => JSON::parse(model.ent_properties),
      :operations => [
        { :href => context.destroy_volume_template_url(model.id), :rel => 'http://schemas.dmtf.org/cimi/1/action/delete' }
      ]
    )
  end



end
