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
      systems.collect {|e| CIMI::Service::System.new(context, :model => e)}
    else
      systems = context.driver.systems(context.credentials, {:env=>context, :id=>id})
      raise CIMI::Model::NotFound unless systems.first
      CIMI::Service::System.new(context, :model=>systems.first)
    end
  end

  def perform(action, &block)
    begin
      op = action.operation
      if context.driver.send(:"#{op}_system", context.credentials, ref_id(id))
        block.callback :success
      else
        raise "Operation #{op} failed to execute on given System #{ref_id(id)}"
      end
    rescue => e
      raise
      block.callback :failure, e.message
    end
  end

  def self.delete!(id, context)
    context.driver.destroy_system(context.credentials, id)
  end


end
