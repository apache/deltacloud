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

class CIMI::Model::Network < CIMI::Model::Base

  ref :network_template, :required => true

  def create(context)
    validate!

    if network_template.href?
      template = network_template.find(context)
    end

    params = {
      :network_config => template.network_config.find(context),
      :forwarding_group => template.forwarding_group.find(context),
      :name => name,
      :description => description,
      :env => context # FIXME: We should not pass the context to the driver (!)
    }

    network = context.driver.create_network(context.credentials, params)
    network.property = property if property
    network.save
    network
  end

end
