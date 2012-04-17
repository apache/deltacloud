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

module Deltacloud
  class StateMachine

    attr_reader :states
    def initialize(&block)
      @states  = []
      instance_eval &block if block
    end

    def start()
      state(:start)
    end

    def finish()
      state(:finish)
    end

    def state(name)
      state = @states.find{|e| e.name == name.to_sym}
      if ( state.nil? )
        state = State.new( self, name.to_sym )
        @states << state
      end
      state
    end

    def method_missing(sym,*args)
      return state( sym ) if ( args.empty? )
      super( sym, *args )
    end

    class State

      attr_reader :name
      attr_reader :transitions

      def initialize(machine, name)
        @machine = machine
        @name    = name
        @transitions = []
      end

      def to_s
        self.name.to_s
      end

      def to(destination_name)
        destination = @machine.state(destination_name)
        transition = Transition.new( @machine, destination )
        @transitions << transition
        transition
      end

    end

    class Transition

      attr_reader :destination
      attr_reader :action

      def initialize(machine, destination)
        @machine = machine
        @destination = destination
        @auto   = false
        @action = nil
      end

      def automatically
        @auto = true
      end

      def automatically?
        @auto
      end

      def on(action)
        @action = action
      end

    end

  end
end
