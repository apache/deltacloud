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

module Deltacloud
class Subnet < BaseModel

  attr_accessor :name
  attr_accessor :network
  attr_accessor :address_block
  attr_accessor :state
  attr_accessor :type

  def to_hash(context)
    {
      :id => id,
      :name => name,
      :href => context.subnet_url(id),
      :type => type,
      :state => state,
      :address_block => address_block,
      :network => {
        :id => network,
        :href => context.network_url(network),
      },
    }
  end

end
end
