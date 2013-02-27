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

module CIMI
  module Helper

    def current_content_type
      case request.content_type
        when 'application/json' then :json
        when 'text/xml', 'application/xml' then :xml
        else
          raise Deltacloud::Exceptions.exception_from_status(
            406,
            translate_error_code(406)[:message]
          )
      end
    end

    def expand?(collection)
      params['$expand'] == '*' ||
        (params['$expand'] || '').split(',').include?(collection.to_s)
    end

    def no_content_with_status(code=200)
      body ''
      status code
    end

    # Set status to 201 and a Location header
    def headers_for_create(resource)
      status 201
      headers 'Location' => resource.id
    end

    def href_id(href, entity)
      split_on = self.send(:"#{entity.to_s}_url")
      href.split("#{split_on}/").last
    end

    def to_kibibyte(value, unit)
      #value may be a string. convert to_f
      value = value.to_f # not to_i because e.g. 0.5 GB
      case unit
      when "GB"
        (value*1024*1024).to_i
      when "MB"
        (value*1024).to_i
      else
        nil # should probably be exploding something here...
      end
    end

    #e.g. convert volume to GB for deltacloud driver
    def from_kibibyte(value, unit="GB")
      case unit
        when "GB" then ((value.to_f)/1024/1024)
        when "MB" then ((value.to_f)/1024)
        else nil
      end
    end

    def deltacloud_create_method_for(cimi_entity)
      case cimi_entity
        when "machine"                then "create_instance"
        when "machine_configuration"  then "create_hardware_profile"
        when "machine_image"          then "create_image"
        when "volume"                 then "create_storage_volume"
        when "volume_image"           then "create_storage_snapshot"
        else "create_#{cimi_entity}"
      end

    end

  end
end
