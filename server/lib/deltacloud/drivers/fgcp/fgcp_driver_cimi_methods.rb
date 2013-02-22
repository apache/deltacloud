#
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
#Definition of CIMI methods for the Fgcp driver - separation from deltacloud
#API Fgcp driver methods

module Deltacloud::Drivers::Fgcp

  class FgcpDriver < Deltacloud::BaseDriver

    #cimi features
    feature :machines, :default_initial_state do
      { :values => ["STOPPED"] }
    end

    def systems(credentials, opts={})
      safely do
        client = new_client(credentials)

        if opts and opts[:id]
          vsys_ids = [opts[:id]]
        else
          xml = client.list_vsys['vsyss']
          return [] if xml.nil?
          vsys_ids = xml[0]['vsys'].collect { |vsys| vsys['vsysId'][0] }
        end

        vsys_ids.collect do |vsys_id|
          vsys = client.get_vsys_configuration(vsys_id)['vsys'][0]
          vsys_description_el = vsys['description']
          CIMI::Model::System.new(
            :id          => vsys['vsysId'][0],
            :name        => vsys['vsysName'][0],
#            :machines    => "http://cimi.example.org/systems/#{vsys['vsysId'][0]}/machines?realm_id=#{vsys['vsysId'][0]}",
#            :volumes     => "http://cimi.example.org/systems/#{vsys['vsysId'][0]}/volumes?realm_id=#{vsys['vsysId'][0]}",
#            :networks    => "http://cimi.example.org/systems/#{vsys['vsysId'][0]}/networks?realm_id=#{vsys['vsysId'][0]}",
#            :addresses   => "http://cimi.example.org/systems/#{vsys['vsysId'][0]}/addresses?realm_id=#{vsys['vsysId'][0]}",
            :description => vsys_description_el ? vsys_description_el[0] : nil
          )
        end
      end
    end

    def system_templates(credentials, opts={})
      safely do
        client = new_client(credentials)
        templates = client.list_vsys_descriptor['vsysdescriptors'][0]['vsysdescriptor'].collect do |desc|
          CIMI::Model::SystemTemplate.new(
            :id           => desc['vsysdescriptorId'][0],
            :name         => desc['vsysdescriptorName'][0],
            :description  => desc['description'][0]
          )
        end
        templates = templates.select { |t| opts[:id] == t[:id] } if opts[:id]
        templates
      end
    end

  end

end
