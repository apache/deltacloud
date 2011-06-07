#
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


class Image < BaseModel

  attr_accessor :name
  attr_accessor :owner_id
  attr_accessor :description
  attr_accessor :architecture
  attr_accessor :state

  alias :to_hash_original :to_hash

  def to_hash
    h = self.to_hash_original
    h.merge({
      :actions => [ :create_instance => {
        :method => 'post',
        :href => "#{Sinatra::UrlForHelper::DEFAULT_URI_PREFIX}/instances;image_id=#{self.id}" 
      }]
    })
  end

end
