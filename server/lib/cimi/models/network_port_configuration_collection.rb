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
class CIMI::Model::NetworkPortConfigurationCollection < CIMI::Model::Base

  act_as_root_entity :network_port_configuration

  text :count

  self << CIMI::Model::NetworkPortConfiguration

  def self.default(context)
    network_port_configurations = CIMI::Model::NetworkPortConfiguration.all(context)
    self.new(
      :id => context.network_port_configurations_url,
      :name => 'default',
      :created => DateTime.now.xmlschema,
      :description => "#{context.driver.name.capitalize} NetworkPortConfigurationCollection",
      :count => network_port_configurations.size,
      :network_port_configurations => network_port_configurations
    )
  end

end
