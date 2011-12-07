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

  CMWG_NAMESPACE = "http://www.dmtf.org/cimi"

  class Application < Sinatra::Base

    use CIMI::Frontend::CloudEntryPoint
    use CIMI::Frontend::MachineConfiguration
    use CIMI::Frontend::MachineImage
    use CIMI::Frontend::Machine
    use CIMI::Frontend::MachineAdmin
    use CIMI::Frontend::MachineTemplate
    use CIMI::Frontend::VolumeConfiguration
    use CIMI::Frontend::VolumeImage
    use CIMI::Frontend::Volume

    configure do
      enable :logging
      enable :layout
      enable :show_exceptions
      enable :dump_errors
      enable :raise_exceptions
      enable :sessions
    end

    get '/' do
      redirect '/cimi/cloudEntryPoint'
    end

    get '/cimi' do
      redirect '/cimi/cloudEntryPoint'
    end
  end

end
