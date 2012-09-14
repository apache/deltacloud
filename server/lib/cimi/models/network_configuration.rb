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

class CIMI::Model::NetworkConfiguration < CIMI::Model::Base

  text :network_type

  text :mtu

  text :class_of_service

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    network_configs = []
    if id==:all
      network_configs = context.driver.network_configurations(context.credentials, {:env=>context})
    else
      network_configs = context.driver.network_configurations(context.credentials, {:env=>context, :id=>id})
    end
    network_configs
  end

  def self.create_from_xml(request_body, context)
  end

  def self.create_from_json(request_body, context)
  end
end
