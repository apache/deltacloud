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

module Deltacloud::Client
  module Methods
    module InstanceState

      # Representation of the current driver state machine
      #
      def instance_states
        r = connection.get(api_uri("instance_states"))
        r.body.to_xml.root.xpath('state').map do |se|
          state = model(:instance_state).new_state(se['name'])
          se.xpath('transition').each do |te|
            state.transitions << model(:instance_state).new_transition(
              te['to'], te['action']
            )
          end
          state
        end
      end

      def instance_state(name)
        instance_states.find { |s| s.name.to_s.eql?(name.to_s) }
      end

    end
  end
end
