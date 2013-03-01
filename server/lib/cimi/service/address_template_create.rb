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

class CIMI::Service::AddressTemplateCreate < CIMI::Service::Base

  def create
    new_template = context.current_db.add_address_template(
      :name => name,
      :description => description,
      :hostname => hostname,
      :ip => ip,
      :allocation => allocation,
      :default_gateway => default_gateway,
      :dns => dns,
      :protocol => protocol,
      :mask => mask,
      :ent_properties => property.to_json
    )
    CIMI::Service::AddressTemplate.from_db(new_template, context)
  end

end
