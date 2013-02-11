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

class CIMI::Model::CredentialCreate < CIMI::Model::Base

  ref :credential_template, :required => true

  def create(context)
    validate!

    unless context.driver.respond_to? :create_key
       raise Deltacloud::Exceptions.exception_from_status(
         501,
         "Creating Credential is not supported by the current driver"
       )
    end

    if credential_template.href?
      template = credential_template.find(ctx)
    else
      template = credential_template
    end

    key = context.driver.create_key(context.credentials, :key_name => name)

    result = CIMI::Model::Credential.from_key(key, context)
    result.name = name if name
    result.description = description if description
    result.property = property if property
    result.save
    result

  end
end
