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
require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative '../spec_helper.rb' if require 'minitest/autorun'

describe "Resource" do

  class ReqResource < CIMI::Model::Resource
    scalar :req, :required => true
  end

  describe "required attributes" do
    it "should require a value" do
      obj = ReqResource.from_json({}.to_json)
      assert_raises CIMI::Model::ValidationError do
        obj.validate!(:json)
      end
    end

    it "should validate numbers" do
      obj = ReqResource.from_json({"req" => 42}.to_json)
      obj.validate!(:json).must_be_nil
    end
  end
end
