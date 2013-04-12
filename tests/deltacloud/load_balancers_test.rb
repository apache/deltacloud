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

$:.unshift File.join(File.dirname(__FILE__), '..')
require "deltacloud/test_setup.rb"

describe 'Deltacloud API load_balancers collection' do
  include Deltacloud::Test::Methods

  need_collection :load_balancers

  LOAD_BALANCERS = "/load_balancers"

  if collection_supported :load_balancers
    #Create a load_balancer
    res = post(LOAD_BALANCERS, :name => "loadBalancerForTest",
       :listener_protocol => "HTTP",
       :listener_balancer_port => "80",
       :listener_instance_port => "3010",
       :realm_id => get_a("realm"))

    unless res.code == 201
      raise Exception.new("Failed to create load balancer")
    end
  end

  #Delete the load_balancer we created for the tests
  MiniTest::Unit.after_tests {
  if collection_supported :load_balancers
    res = delete(LOAD_BALANCERS + "/loadBalancerForTest")
    unless res.code == 204
     raise Exception.new("Failed to delete load balancer")
    end
  end
  }

  #Run the 'common' tests for all collections defined in common_tests_collections.rb
  CommonCollectionsTest::run_collection_and_member_tests_for("load_balancers")

end
