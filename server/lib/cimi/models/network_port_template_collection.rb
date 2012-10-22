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

class CIMI::Model::NetworkPortTemplateCollection < CIMI::Model::Base

  CIMI::Model.register_as_root_entity! "NetworkPortTemplates"

  text :count

  #add array of network_port_templates:
  self << CIMI::Model::NetworkPortTemplate

  def self.default(context)
    network_port_templates = CIMI::Model::NetworkPortTemplate.all(context)
    self.new(
      :id => context.network_port_templates_url,
      :name => 'default',
      :created => DateTime.now.xmlschema,
      :description => "#{context.driver.name.capitalize} NetworkPortTemplateCollection",
      :count => network_port_templates.size,
      :network_port_templates => network_port_templates
    )
  end

end
