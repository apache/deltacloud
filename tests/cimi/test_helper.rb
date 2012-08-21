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
require 'require_relative'
require_relative '../helpers/common.rb'

require 'singleton'
require_relative "../../server/lib/cimi/models"

# Add CIMI specific config stuff
module CIMI
  module Test
    class Config

      include Singleton

      def initialize
        @hash = Deltacloud::Test::yaml_config
        @cimi = @hash["cimi"]
      end

      def cep_url
        @cimi["cep"]
      end

      def collections
        xml.xpath("/c:CloudEntryPoint/c:*[@href]", ns).map { |c| c.name }
      end

      def features
        {}
      end

      def ns
        { "c" => "http://www.dmtf.org/cimi" }
      end

      private
      def xml
        unless @xml
          @xml = RestClient.get(cep_url, "Accept" => "application/xml").xml
        end
        @xml
      end
    end

    def self.config
      Config::instance
    end
  end
end

module CIMI::Test::Methods

  module Global
    def api
      CIMI::Test::config
    end

    def cep(params = {})
      get(api.cep_url, params)
    end

    def get(path, params = {})
      RestClient.get path, headers(params)
    end

    private
    def headers(params)
      headers = {}
      if params[:accept]
        headers["Accept"] = "application/#{params.delete(:accept)}" if params[:accept]
      else #default to xml
        headers["Accept"] = "application/xml"
      end
      headers
    end
  end

  module ClassMethods
    def need_collection(name)
      before :each do
        unless api.collections.include?(name.to_sym)
          skip "Server at #{api.cep_url} doesn't support #{name}"
        end
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.extend Global
    base.send(:include, Global)
  end
end

# Special spec class for 'behavior' tests that need to be run once
# for XML and once for JSON
class CIMI::Test::Spec < MiniTest::Spec
  include CIMI::Test::Methods

  CONTENT_TYPES = { :xml => "application/xml",
    :json => "application/json" }

  def use_format(fmt)
    @format = fmt
    @content_type = CONTENT_TYPES[fmt]
  end

  def self.it desc = "anonymous", &block
    block ||= proc { skip "(no tests defined)" }

    CONTENT_TYPES.keys.each do |fmt|
      super("#{desc} [#{fmt}]") do
        use_format(fmt)
        instance_eval &block
      end
    end
  end

  def self.model(name, model_class, opts = {}, &block)
    define_method name do
      @_memoized ||= {}
      @@_cache ||= {}
      @_memoized.fetch("#{name}_#{@format}") do |k|
        if opts[:cache]
          @_memoized[k] = @@_cache.fetch(k) do |k|
            @@_cache[k] = fetch_model(k, model_class, &block)
          end
        else
          @_memoized[k] = fetch_model(k, model_class, &block)
        end
      end
    end
  end

  def last_response
    @@_cache ||= {}
    @@_cache[:last_response]
  end

  private

  def fetch_model(k, model_class, &block)
    response = instance_exec(@format, &block)
    @@_cache[:last_response] = response
    assert_equal @content_type, response.headers[:content_type]
    # FIXME: for XML check that the correct namespace is set
    model_class.parse(response.body, @content_type)
  end
end

MiniTest::Spec.register_spec_type(/Behavior$/, CIMI::Test::Spec)
