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

      def base_uri
        xml.xpath("/c:CloudEntryPoint/c:baseURI", ns).text
      end

      def basic_auth(u = nil, p = nil)
        u ||= @cimi["user"]
        p ||= @cimi["password"]
        "Basic #{Base64.encode64("#{u}:#{p}")}"
      end

      def collections
        xml.xpath("/c:CloudEntryPoint/c:*[@href]", ns).map { |c| c.name.to_sym }
      end

      def features
        {}
      end

      def ns
        { "c" => "http://schemas.dmtf.org/cimi/1" }
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
      RestClient.get absolute_url(path), headers(params)
    end

    private
    def absolute_url(path)
      if path.start_with?("http")
        path
      elsif path.start_with?("/")
        api.base_uri + path
      else
        api.base_uri + "/#{path}"
      end
    end

    def headers(params)
      headers = {
        'Authorization' => api.basic_auth
      }
      if params[:accept]
        headers["Accept"] = "application/#{params.delete(:accept)}"
      else
        # @content_type is set by the harness below
        # if it isn't, default to XML
        headers["Accept"] = @content_type || "application/xml"
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

    # Perform basic collection checks; +model_name+ is the name of the
    # method returning the collection model; +member_class+ is the class
    # for the model of individual entries
    def check_collection(model_name, member_class)
      it "must have the \"id\" and \"count\" attributes" do
        coll = self.send(model_name)
        coll.count.wont_be_nil
        coll.count.to_i.must_equal coll.entries.size
        coll.id.must_be_uri
      end

      it "must have a valid id and name for each member" do
        self.send(model_name).entries.each do |entry|
          entry.id.must_be_uri
          member = fetch(entry.id, member_class)
          member.id.must_equal entry.id
          member.name.must_equal entry.name
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

  def fetch(uri, model_class)
    fetch_model(uri, model_class) { |fmt| get(uri, :accept => fmt) }
  end

  def self.it desc = "anonymous", opts = {}, &block
    block ||= proc { skip "(no tests defined)" }

    if opts[:only]
      super("#{desc}") do
        use_format(opts[:only])
        instance_eval &block
      end
    else
      CONTENT_TYPES.keys.each do |fmt|
        super("#{desc} [#{fmt}]") do
          use_format(fmt)
          instance_eval &block
        end
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
    @@_cache[:last_response] ||= {}
    @@_cache[:last_response][@format]
  end

  private

  def fetch_model(k, model_class, &block)
    response = instance_exec(@format, &block)
    @@_cache[:last_response] ||= {}
    @@_cache[:last_response][@format] = response
    assert_equal @content_type, response.headers[:content_type]
    # FIXME: for XML check that the correct namespace is set
    model_class.parse(response.body, @content_type)
  end
end

MiniTest::Spec.register_spec_type(/Behavior$/, CIMI::Test::Spec)
