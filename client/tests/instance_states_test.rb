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

require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/

require_relative './test_helper.rb'

describe "Instance States" do

  it "should allow retrieval of instance-state information" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance_states = client.instance_states
      instance_states.wont_be_nil
      instance_states.wont_be_empty

      instance_states[0].name.must_equal 'start'
      instance_states[0].transitions.size.must_equal 1
      instance_states[0].transitions[0].wont_equal :auto

      instance_states[1].name.must_equal 'pending'
      instance_states[1].transitions.size.must_equal 1
      instance_states[1].transitions[0].wont_equal :auto

      instance_states[2].name.must_equal 'running'
      instance_states[2].transitions.size.must_equal 2
      includes_transition( instance_states[2].transitions, :reboot, :running ).must_equal true
      includes_transition( instance_states[2].transitions, :stop, :stopped ).must_equal true
    end
  end

  it "should allow retrieval of a single instance-state blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance_state = client.instance_state( :pending )
      instance_state.wont_be_nil
      instance_state.name.must_equal 'pending'
      instance_state.transitions.size.must_equal 1
      instance_state.transitions[0].wont_equal :auto

      instance_state = client.instance_state( :running )
      instance_state.name.must_equal 'running'
      instance_state.transitions.size.must_equal 2
      includes_transition( instance_state.transitions, :reboot, :running ).must_equal true
      includes_transition( instance_state.transitions, :stop, :stopped ).must_equal true
    end
  end

  def includes_transition( transitions, action, to )
    found = transitions.find{|e| e.action.to_s == action.to_s && e.to.to_s == to.to_s }
    ! found.nil?
  end


end
