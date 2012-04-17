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

class CIMI::Model::MachineAdmin < CIMI::Model::Base

  text :username
  text :password
  text :key

  array :operations do
    scalar :rel, :href
  end

  def self.find(id, context)
    if id == :all
      keys = context.driver.keys(context.credentials)
      keys.map { |key| from_key(key, context) }
    else
      key = context.driver.key(context.credentials, :id => id)
      from_key(key, context)
    end
  end

  def self.create_from_xml(body, context)
    machine_admin = MachineAdmin.from_xml(body)
    key = context.driver.create_key(context.credentials, :key_name => machine_admin.name)
    from_key(key, context)
  end

  def self.delete!(id, context)
    context.driver.destroy_key(context.credentials, :id => id)
  end

  private

  def self.from_key(key, context)
    self.new(
      :name => key.id,
      :username => key.username,
      :password => key.is_password? ? key.password : key.fingerprint,
      :key => key.is_key? ? key.pem_rsa_key : nil,
      :id => context.machine_admin_url(key.id),
      :created => Time.now
    )
  end

end
