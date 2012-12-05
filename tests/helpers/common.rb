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

require 'rubygems'
require 'minitest/autorun'
require 'rest_client'
require 'nokogiri'
require 'json'
require 'base64'
require 'yaml'

module RestClient::Response
  def xml
    @xml ||= Nokogiri::XML(body)
  end

  def json
    @json ||= JSON.parse(body)
  end
end

class String
  def singularize
    return self.gsub(/ies$/, 'y') if self =~ /ies$/
    return self.gsub(/es$/, '') if self =~ /sses$/
    self.gsub(/s$/, '')
  end
  def pluralize
    return self + 'es' if self =~ /ess$/
    return self[0, self.length-1] + "ies" if self =~ /ty$/
    return self if self =~ /data$/
    self + "s"
  end
end

class Array
  alias :original_method_missing :method_missing

  def method_missing(name, *args)
    if name == :choice
      return self.sample(*args)
    end
    original_method_missing(name, *args)
  end
end

module Deltacloud
  module Test

    def self.yaml_config
      fname = ENV["CONFIG"] || File::join(File::dirname(__FILE__), "..",
                                          "config.yaml")
      YAML.load(File::open(fname))
    end
  end
end

# Add an assertion for URI's
module MiniTest::Assertions
  def assert_uri(obj, msg = nil)
    msg = message(msg) { "Expected #{mu_pp(obj)} to be a valid URI" }
    refute_nil obj, msg
    refute_empty obj, msg
    begin
      u = URI.parse(obj)
      refute_nil u.path, msg
    rescue => e
      fail "Could not parse URI #{mu_pp(obj)}"
    end
  end
end

MiniTest::Expectations::infect_an_assertion :assert_uri, :must_be_uri, :unary
MiniTest::Expectations::infect_an_assertion :assert_includes, :must_be_one_of
