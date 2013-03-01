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

class CIMI::Service::MachineCreate < CIMI::Service::Base

  def create
    params = {}
    if machine_template.href
      template = resolve(machine_template)
      params[:hwp_id] = ref_id(template.machine_config.href)
      params[:initial_state] = template.initial_state
      image_id = ref_id(template.machine_image.href)
    else
      # FIXME: What if either of these href's isn't there ? What if the user
      # tries to override some aspect of the machine_config/machine_image ?
      params[:hwp_id] = ref_id(machine_template.machine_config.href)
      params[:initial_state] = machine_template.initial_state
      image_id = ref_id(machine_template.machine_image.href)
      if machine_template.credential.href
        params[:keyname] = ref_id(machine_template.credential.href)
      end
    end

    params[:name] = name if name
    params[:realm_id] = realm if realm
    instance = context.driver.create_instance(context.credentials, image_id, params)

    result = CIMI::Service::Machine::from_instance(instance, context)
    result.name = name if name
    result.description = description if description
    result.property = property if property
    result.save
    result
  end


end
