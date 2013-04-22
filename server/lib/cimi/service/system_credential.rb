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

class CIMI::Service::SystemCredential < CIMI::Service::Base

  def self.find(system_id, context, id=:all)
    if id == :all
      credentials = context.driver.system_credentials(context.credentials, {:env=>context, :system_id=>system_id})
      credentials.collect {|e| CIMI::Service::SystemCredential.new(context, :model => e)}
    else
      credentials = context.driver.system_credentials(context.credentials, {:env=>context, :system_id=>system_id, :id=>id})
      raise CIMI::Model::NotFound if credentials.empty?
      CIMI::Service::SystemCredential.new(context, :model => credentials.first)
    end
  end

  def self.collection_for_system(system_id, context)
    system_credentials = self.find(system_id, context)
    credentials_url = context.system_credentials_url(system_id) if context.driver.has_capability? :add_credentials_to_system
    CIMI::Model::SystemCredential.list(credentials_url, system_credentials, :add_url => credentials_url)
  end

end
