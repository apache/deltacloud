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
class CIMI::Model::NetworkCollection < CIMI::Model::Base

  act_as_root_entity :network
  text :count

#add networks Array:
  self.schema.add_collection_member_array(CIMI::Model::Network)

  def self.default(context)
    networks = CIMI::Model::Network.all(context)
    self.new(
      :id => context.networks_url,
      :name => 'default',
      :created => Time.now,
      :description => "#{context.driver.name.capitalize} NetworkCollection",
      :count => networks.size,
      :networks => networks
    )
  end

end
