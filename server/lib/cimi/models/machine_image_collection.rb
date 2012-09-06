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

class CIMI::Model::MachineImageCollection < CIMI::Model::Base

  act_as_root_entity :machine_image

  text :count

  self << CIMI::Model::MachineImage

  def self.default(context)
    machine_images = CIMI::Model::MachineImage.all(context)
    self.new(
      :id => context.machine_images_url,
      :name => 'default',
      :created => Time.now,
      :description => "#{context.driver.name.capitalize} MachineImageCollection",
      :count => machine_images.count,
      :machine_images => machine_images
    )
  end

end
