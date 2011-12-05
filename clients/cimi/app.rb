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

module CIMI::Frontend

  class Application < Sinatra::Base
    use CIMI::Frontend::CloudEntryPoint
    use CIMI::Frontend::MachineConfiguration
    use CIMI::Frontend::MachineImage
    use CIMI::Frontend::Machine
    use CIMI::Frontend::MachineTemplate
    use CIMI::Frontend::VolumeConfiguration
    use CIMI::Frontend::VolumeImage
    use CIMI::Frontend::Volume

    configure do
      enable :logging
      enable :show_exceptions
      enable :dump_errors
      enable :raise_exceptions
    end

    get '/' do
      redirect '/cimi/cloudEntryPoint'
    end

    get '/cimi' do
      redirect '/cimi/cloudEntryPoint'
    end
  end

  private

  def self.client
    RestClient::Resource.new(ENV['CIMI_API_URL'])
  end

  def self.get_entity(entity_type, id, credentials)
    client['%s/%s' % [entity_type, id]].get(auth_header(credentials))
  end

  def self.get_entity_collection(entity_type, credentials)
    client[entity_type].get(auth_header(credentials))
  end

  def self.auth_header(credentials)
    encoded_credentials = ["#{credentials.user}:#{credentials.password}"].pack("m0").gsub(/\n/,'')
    { :authorization => "Basic " + encoded_credentials }
  end

end
