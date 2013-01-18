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

  CMWG_NAMESPACE = "http://schemas.dmtf.org/cimi/1"

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
    use CIMI::Frontend::Network
    use CIMI::Frontend::NetworkConfiguration
    use CIMI::Frontend::NetworkPortConfiguration
    use CIMI::Frontend::NetworkPortTemplate
    use CIMI::Frontend::NetworkTemplate
    use CIMI::Frontend::NetworkPort
    use CIMI::Frontend::RoutingGroup
    use CIMI::Frontend::RoutingGroupTemplate
    use CIMI::Frontend::VSP
    use CIMI::Frontend::VSPConfiguration
    use CIMI::Frontend::VSPTemplate
    use Rack::Session::Cookie

    helpers CIMI::Frontend::Helper

    before do
      @_flash, session[:_flash] = session[:_flash], nil if session[:_flash]
    end

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

    get '/driver' do
      unless params[:driver]
        flash[:error] = "You need to choose driver"
        redirect(back) && return
      end
      session[:provider] = param_if_not_nil(params, :provider)
      session[:driver] = param_if_not_nil(params, :driver)
      session[:username] = param_if_not_nil(params, :username)
      session[:password] = param_if_not_nil(params, :password)
      flash[:success] = "You're now using #{session[:driver].to_s.upcase}"
      redirect back
    end

    private

    def param_if_not_nil(params, param)
      return false if params[param].nil?
      return false if params[param].strip.empty?
      return params[param].strip
    end

  end

end
