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
#

require 'deltacloud/drivers/rackspace/rackspace_driver.rb'
module Deltacloud
  module Drivers
    module Openstack
      class OpenstackDriver < Rackspace::RackspaceDriver

        feature :instances, :user_name
        feature :instances, :authentication_password
        feature :instances, :user_files

        define_instance_states do
          start.to( :pending )          .on( :create )
          pending.to( :running )        .automatically
          running.to( :running )        .on( :reboot )
          running.to( :shutting_down )  .on( :stop )
          shutting_down.to( :stopped )  .automatically
          stopped.to( :finish )         .automatically
        end

        def new_client(credentials)
          safely do
            CloudServers::Connection.new(:username => credentials.user, :api_key => credentials.password, :auth_url => api_provider)
          end
        end

        private :new_client
      end
    end
  end
end

