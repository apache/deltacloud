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
require 'logger'

# Add CIMI specific config stuff
module CIMI
  module Test

    CIMI_NAMESPACE = "http://schemas.dmtf.org/cimi/1"

    class Config

      include Singleton

      def initialize
        @hash = Deltacloud::Test::yaml_config
        @cimi = @hash["cimi"]
        @preferred = @cimi["preferred"]
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

      def provider_perferred_image
        @preferred["machine_image"]
      end

      def provider_perferred_config
        @preferred["machine_config"]
      end

      def provider_perferred_volume_config
        @preferred["volume_config"]
      end

      def collections
        xml.xpath("/c:CloudEntryPoint/c:*[@href]", ns).map { |c| c.name.to_sym }
      end

      def features
        {}
      end

      def ns
        { "c" => CIMI_NAMESPACE }
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

    # Find the model class that can process the body of the HTTP response
    # +resp+
    def model_class(resp)
      resource = nil
      ct = resp.headers[:content_type]
      if ct == "application/json"
        resource = resp.json["resourceURI"].split("/").last
      elsif ct == "application/xml"
        if resp.xml.root.name == "Collection"
          resource = resp.xml.root["resourceURI"].split("/").last
        else
          resource = resp.xml.root.name
        end
      else
        raise "Unexpected content type #{response.content_type}"
      end
      CIMI::Model::const_get(resource)
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

    # Adding logging capability
    def log
      unless @log
        @log = Logger.new(STDOUT)
        if ENV['LOG_LEVEL'].nil?
          @log.level = Logger::WARN
        else
          @log.level = Logger.const_get ENV['LOG_LEVEL']
        end
      end
      @log
    end

    def poll_state(machine, state)
      while not machine.state.upcase.eql?(state)
        puts state
        puts 'waiting for machine to be: ' + state.to_s()
        sleep(10)
        machine = machine(:refetch => true)
      end
    end

    def machine_stop_start(machine, action, state)
      response = RestClient.post( machine.id + "/" + action,
            "<Action xmlns=\"http://schemas.dmtf.org/cimi/1\">" +
              "<action> http://http://schemas.dmtf.org/cimi/1/action/" + action + "</action>" +
            "</Action>",
            {'Authorization' => api.basic_auth, :accept => :xml })
      response.code.must_equal 202
      poll_state(machine(:refetch => true), state)
      machine(:refetch => true).state.upcase.must_equal state
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
    # method returning the collection model
    def check_collection(model_name)
      it "must have the \"id\" and \"count\" attributes" do
        coll = self.send(model_name)
        coll.count.wont_be_nil
        coll.count.to_i.must_equal coll.entries.size
        coll.id.must_be_uri
      end

      it "must have a valid id and name for each member" do
        self.send(model_name).entries.each do |entry|
          entry.id.must_be_uri
          member = fetch(entry.id)
          member.id.must_equal entry.id
          member.name.must_equal entry.name
        end
      end
    end

    # Cleanup: stop/destroy the resources created for the tests
    def teardown(created_resources, api_basic_auth)
      @@created_resources = created_resources
      puts "CLEANING UP... resources for deletion: #{@@created_resources.inspect}"

      # machines:
      if not @@created_resources[:machines].nil?
        @@created_resources[:machines].each_index do |i|
          attempts = 0
          begin
            stop_res = RestClient.post( @@created_resources[:machines][i] + "/stop",
            "<Action xmlns=\"http://schemas.dmtf.org/cimi/1\">" +
            "<action> http://http://schemas.dmtf.org/cimi/1/action/stop</action>" +
            "</Action>",
            {'Authorization' => api.basic_auth, :accept => :xml } )

            if stop_res.code == 202

              model_state = RestClient.get( @@created_resources[:machines][i],
              {'Authorization' => api_basic_auth, :accept => :json} ).json["state"]

              while not model_state.upcase.eql?("STOPPED")
                puts 'waiting for machine to be STOPPED'
                sleep(10)
                model_state = RestClient.get( @@created_resources[:machines][i],
                {'Authorization' => api_basic_auth, :accept => :json} ).json["state"]
              end
            end
            delete_res = RestClient.delete( @@created_resources[:machines][i],
            {'Authorization' => api_basic_auth, :accept => :json} )
            @@created_resources[:machines][i] = nil if delete_res.code == 200
          rescue Exception => e
            sleep(10)
            attempts += 1
            retry if (attempts <= 5)
          end
        end

        @@created_resources[:machines].compact!
        @@created_resources.delete(:machines) if @@created_resources[:machines].empty?
      end

      # machine_image, machine_volumes, other collections
      if (not @@created_resources[:machine_images].nil?) &&
      (not @@created_resources[:volumes].nil?)
        [:machine_images, :volumes].each do |col|
          @@created_resources[col].each do |k|
            attempts = 0
            begin
              puts "#{k}"
              res = RestClient.delete( "#{k}",
              {'Authorization' => api_basic_auth, :accept => :json} )
              @@created_resources[col].delete(k) if res.code == 200
            rescue Exception => e
              sleep(10)
              attempts += 1
              retry if (attempts <= 5)
            end
          end
          @@created_resources.delete(col) if @@created_resources[col].empty?
        end
      end

      puts "CLEANUP attempt finished... resources looks like: #{@@created_resources.inspect}"
      raise Exception.new("Unable to delete all created resources - please check: #{@@created_resources.inspect}") unless @@created_resources.empty?
    end

    def query_the_cep(collections = [])
      it "should have root collections" do
        cep = self.send(:subject)
        collections.each do |root|
          r = root.underscore.to_sym
          if cep.respond_to?(r)
            log.info( "Testing collection: " + root )
            coll = cep.send(r)
            coll.must_respond_to :href, "#{root} collection"
            unless coll.href.nil?
              coll.href.must_be_uri "#{root} collection"
              model = fetch(coll.href)
              last_response.code.must_equal 200
              if last_response.headers[:content_type].eql?("application/json")
                last_response.json["resourceURI"].wont_be_nil
              end
            else
              log.info( root + " is not supported by this provider." )
            end
          end
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

  def fetch(uri)
    resp = retrieve(uri) { |fmt| get(uri, :accept => fmt) }
    parse(resp)
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

  def self.model(name, opts = {}, &block)
    define_method name do |*args|
      @_memoized ||= {}
      @@_cache ||= {}
      if args[0].is_a?(Hash)
        if args[0][:refetch]
          k = "#{name}_#{@format}"
          @_memoized.delete(k)
          @@_cache.delete(k)
        end
      end

      resp = @_memoized.fetch("#{name}_#{@format}") do |k|
        if opts[:cache]
          @_memoized[k] = @@_cache.fetch(k) do |k|
            @@_cache[k] = retrieve(k, &block)
          end
        else
          @_memoized[k] = retrieve(k, &block)
        end
      end
      @@_cache[:last_response] ||= {}
      @@_cache[:last_response][@format] = resp
      parse(resp)
    end
  end

  def last_response
    @@_cache ||= {}
    @@_cache[:last_response] ||= {}
    @@_cache[:last_response][@format]
  end

  def setup
   unless defined? @@created_resources
     # Keep track of what collections were created for deletion after tests:
     @@created_resources = {:machines=>[], :machine_images=>[], :volumes=>[]}
   end
   @@created_resources
 end

  private

  def parse(response)
    model_class(response).parse(response.body, @content_type)
  end

  def retrieve(k, &block)
    response = instance_exec(@format, &block)
    assert_equal @content_type, response.headers[:content_type]
    if @format == :xml
      response.xml.namespaces["xmlns"].must_equal CIMI::Test::CIMI_NAMESPACE
    end
    response
  end
end

MiniTest::Spec.register_spec_type(/Behavior$/, CIMI::Test::Spec)
