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

class CIMI::Model::MachineTemplate < CIMI::Model::Base

  href :machine_config
  href :machine_image
  href :machine_admin

  array :volumes do
    scalar :href
    scalar :protocol
    scalar :attachment_point
  end

  array :volume_templates do
    scalar :href, :attachment_point, :protocol
  end

  array :network_interfaces do
    href :vsp
    text :hostname, :mac_address, :state, :protocol, :allocation
    text :address, :default_gateway, :dns, :max_transmission_unit
  end

  array :operations do
    scalar :rel, :href
  end
end
