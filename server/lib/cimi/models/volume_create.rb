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

class CIMI::Model::VolumeCreate < CIMI::Model::Base

  ref :volume_template, :required => true

  def create(context)
    validate!

    if volume_template.href?
      template = volume_template.find(context)
    else
      template = CIMI::Model::VolumeTemplate.from_xml(volume_template.to_xml)
    end

    volume_image = template.volume_image.href? ?
      template.volume_image.find(context) : template.volume_image

    volume_config = template.volume_config.href? ?
      template.volume_config.find(context) : template.volume_config

    params = {
      :name => name,
      :capacity => volume_config.capacity,
      :snapshot_id => ref_id(volume_image.id),
    }

    unless context.driver.respond_to? :create_storage_volume
       raise Deltacloud::Exceptions.exception_from_status(
         501,
         "Creating Volume is not supported by the current driver"
       )
    end

    volume = context.driver.create_storage_volume(context.credentials, params)

    result = CIMI::Model::Volume.from_storage_volume(volume, context)
    result.name = name if result.name.nil?
    result.description = description if description
    result.property = property if property
    result.save
    result
  end

end
