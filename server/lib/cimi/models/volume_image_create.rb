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

class CIMI::Model::VolumeImageCreate < CIMI::Model::Base

  href :image_location
  text :image_data
  text :bootable, :required => true

  def create(context)
    validate!

    params = {
      :volume_id => context.href_id(image_location.href, :volumes),
      :name => name,
      :description => description
    }

    unless context.driver.respond_to? :create_storage_snapshot
      raise Deltacloud::Exceptions.exception_from_status(
        501,
        'Creating VolumeImage is not supported by the current driver'
      )
    end

    new_snapshot = context.driver.create_storage_snapshot(context.credentials, params)
    result = CIMI::Model::VolumeImage.from_storage_snapshot(new_snapshot, context)
    result.name= name unless new_snapshot.name
    result.description = description unless new_snapshot.description
    result.property = property if property
    result.save
    result
  end

end
