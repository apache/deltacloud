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

class CIMI::Model::VSP < CIMI::Model::Base

  text :state

  href :network

  text :bandwidth_reservation

  text :traffic_priority

  text :max_traffic_delay

  text :max_traffic_loss

  text :max_traffic_jitter

  href :event_log

  array :meters do
    scalar :href
  end

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    if id==:all
      context.driver.vsps(context.credentials, {:env=>context})
    else
      context.driver.vsps(context.credentials, {:id=>id, :env=>context})
    end
  end

end
