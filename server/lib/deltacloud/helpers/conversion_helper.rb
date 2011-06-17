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


require 'deltacloud/base_driver'

module ConversionHelper

  def convert_to_json(type, obj)
    if ( [ :image, :realm, :instance, :storage_volume, :storage_snapshot, :hardware_profile, :key, :bucket, :blob, :firewall, :load_balancer, :address ].include?( type ) )
      if Array.eql?(obj.class)
        data = obj.collect do |o|
          o.to_hash.merge({ :href => self.send(:"#{type}_url", type.eql?(:hardware_profile) ? o.name : o.id ) })
        end
        type = type.to_s.pluralize
      else
        data = obj.to_hash
        if type == :blob
          data.merge!({ :href => self.send(:"bucket_url", "#{data[:bucket]}/#{data[:id]}" ) })
        else
          data.merge!({ :href => self.send(:"#{type}_url", data[:id]) })
        end
      end
      return { :"#{type}" => data }.to_json
    end
  end

end
