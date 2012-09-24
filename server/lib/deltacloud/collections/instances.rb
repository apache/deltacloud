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

module Deltacloud::Collections
  class Instances < Base

    include Deltacloud::Features

    set :capability, lambda { |m| driver.respond_to? m }
    check_features :for => lambda { |c, f| driver.class.has_feature?(c, f) }

    new_route_for(:instances) do
      @instance = Instance.new( { :id=>params[:id], :image_id=>params[:image_id] } )
      @image   = Image.new( :id => params[:image_id] )
      @hardware_profiles = driver.hardware_profiles(credentials, :architecture => @image.architecture )
      @realms = [Realm.new(:id => params[:realm_id])] if params[:realm_id]
      @realms ||= driver.realms(credentials)
      @firewalls = driver.firewalls(credentials) if driver.class.has_feature? :instances, :firewalls
      @keys = driver.keys(credentials) if driver.class.has_feature? :instances, :authentication_key
    end

    get '/instances/:id/run' do
      respond_to do |format|
        @instance = driver.instances(credentials, :id => params[:id]).first
        format.html {haml :"instances/run_command" }
      end
    end

    collection :instances do

      standard_show_operation
      standard_index_operation

      operation :create, :with_capability => :create_instance do
        param :image_id,     :string, :required
        param :realm_id,     :string, :optional
        param :hwp_id,       :string, :optional
        param :keyname,      :string, :optional
        control do
          @instance = driver.create_instance(credentials, params[:image_id], params)
          if @instance.kind_of? Array
            @elements = @instance
            action_handler = "index"
          else
            response['Location'] = instance_url(@instance.id)
            action_handler = "show"
          end
          status 201  # Created
          respond_to do |format|
            format.xml  { haml :"instances/#{action_handler}" }
            format.json { xml_to_json("instances/#{action_handler}") }
            format.html do
              if @elements
                haml :"instances/index"
              elsif @instance and @instance.id
                response['Location'] = instance_url(@instance.id)
                haml :"instances/show"
              else
                redirect instances_url
              end
            end
          end
        end
      end

      action :reboot, :with_capability => :reboot_instance do
        description "Reboot a running instance."
        param :id, :string, :required
        control { instance_action(:reboot) }
      end

      action :start, :with_capability => :start_instance do
        description "Start an instance."
        param :id, :string, :required
        control { instance_action(:start) }
      end

      action :stop, :with_capability => :stop_instance do
        description "Stop a running instance."
        param :id, :string, :required
        control { instance_action(:stop) }
      end

      operation :destroy, :with_capability => :destroy_instance do
        control { instance_action(:destroy) }
      end

      action :run, :with_capability => :run_on_instance do
        param :id,          :string,  :required
        param :cmd,         :string,  :required, [], "Shell command to run on instance"
        param :private_key, :string,  :optional, [], "Private key in PEM format for authentication"
        param :password,    :string,  :optional, [], "Password used for authentication"
        param :ip,          :string,  :optional, [], "IP address of target instance"
        param :port,        :string,  :optional, ['22'], "Target port"
        control do
          @output = driver.run_on_instance(credentials, params)
          respond_to do |format|
            format.xml { haml :"instances/run" }
            format.html { haml :"instances/run" }
          end
        end
      end
    end

  end
end
