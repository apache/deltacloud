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

class CIMI::Service::SystemMachine < CIMI::Service::Base

  def self.find(system_id, context, id=:all)
    if id == :all
      machines = context.driver.system_machines(context.credentials, {:env=>context, :system_id=>system_id})
      machines.collect {|e| CIMI::Service::SystemMachine.new(context, :model => e)}
    else
      machines = context.driver.system_machines(context.credentials, {:env=>context, :system_id=>system_id, :id=>id})
      raise CIMI::Model::NotFound if machines.empty?
      CIMI::Service::SystemMachine.new(context, :model => machines.first)
    end
  end

  def self.collection_for_system(system_id, context)
    system_machines = self.find(system_id, context)
    machines_url = context.system_machines_url(system_id)
    CIMI::Model::SystemMachine.list(machines_url, system_machines, :add_url => (context.driver.has_capability?(:create_system_machine) ? machines_url : nil))
  end

end
