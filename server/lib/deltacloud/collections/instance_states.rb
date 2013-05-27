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

  class InstanceStates < Base

    set :capability, lambda { |m| !driver.send(m).nil? }

    collection :instance_states do
      operation :index, :with_capability => :instance_state_machine do
        control do
          @machine = driver.instance_state_machine
          respond_to do |format|
            format.xml { haml :'instance_states/show', :layout => false, :locals => { :machine => @machine } }
            format.json do
              out = []
              @machine.states.each do |state|
                transitions = state.transitions.collect do |t|
                  t.automatically? ? {:to => t.destination, :auto => 'true'} : {:to => t.destination, :action => t.action}
                end
                out << { :name => state, :transitions => transitions }
              end
              out.to_json
            end
            format.html { haml :'instance_states/show', :locals => { :machine => @machine }}
            format.gv { erb :"instance_states/show", :locals => { :machine => @machine } }
            format.png do
              # Trick respond_to into looking up the right template for the
              # graphviz file
              gv = erb(:"instance_states/show", :locals => { :machine => @machine })
              png =  ''
              cmd = 'dot -Kdot -Gpad="0.2,0.2" -Gsize="5.0,8.0" -Gdpi="180" -Tpng'
              ::Open3.popen3( cmd ) do |stdin, stdout, stderr|
                stdin.write( gv )
                stdin.close()
                png = stdout.read
              end rescue Errno::EPIPE
              content_type 'image/png'
              png
            end
          end
        end
      end
    end

  end
end
