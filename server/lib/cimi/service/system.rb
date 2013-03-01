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

class CIMI::Service::System < CIMI::Service::Base

  def self.find(id, context)
    if id == :all
      systems = context.driver.systems(context.credentials, {:env=>context})
    else
      systems = context.driver.systems(context.credentials, {:env=>context, :id=>id})
      raise CIMI::Model::NotFound unless systems.first
      systems.first
    end
  end

  def perform(action, context, &block)
    begin
      if context.driver.send(:"#{action.name}_system", context.credentials, self.id.split("/").last)
        block.callback :success
      else
        raise "Operation failed to execute on given System"
      end
    rescue => e
      block.callback :failure, e.message
    end
  end

  def self.delete!(id, context)
    context.driver.destroy_system(context.credentials, id)
  end


end
