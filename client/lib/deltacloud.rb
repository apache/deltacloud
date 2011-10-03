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

require 'nokogiri'
require 'rest_client'
require 'base64'
require 'logger'
require 'hwp_properties'
require 'instance_state'
require 'documentation'
require 'base_object'
require 'client_bucket_methods'

module DeltaCloud

  # Get a new API client instance
  #
  # @param [String, user_name] API user name
  # @param [String, password] API password
  # @param [String, url] API URL (eg. http://localhost:3001/api)
  # @return [DeltaCloud::API]
  #def self.new(user_name, password, api_url, opts={}, &block)
  #  opts ||= {}
  #  API.new(user_name, password, api_url, opts, &block)
  #end

  def self.new(user_name, password, api_url, &block)
    API.new(user_name, password, api_url, &block)
  end

  # Check given credentials if their are valid against
  # backend cloud provider
  #
  # @param [String, user_name] API user name
  # @param [String, password] API password
  # @param [String, user_name] API URL (eg. http://localhost:3001/api)
  # @return [true|false]
  def self.valid_credentials?(user_name, password, api_url, opts={})
    api=API.new(user_name, password, api_url, opts)
    result = false
    api.request(:get, '', :force_auth => '1') do |response|
      result = true if response.code.eql?(200)
    end
    return result
  end

  # Return a API driver for specified URL
  #
  # @param [String, url] API URL (eg. http://localhost:3001/api)
  def self.driver_name(url)
    API.new(nil, nil, url).driver_name
  end

  class API
    attr_reader :api_uri, :driver_name, :api_version, :features, :entry_points
    attr_reader :api_driver, :api_provider

    def initialize(user_name, password, api_url, opts={}, &block)
      opts[:version] = true
      @api_driver, @api_provider = opts[:driver], opts[:provider]
      @username, @password = opts[:username] || user_name, opts[:password] || password
      @api_uri = URI.parse(api_url)
      @features, @entry_points = {}, {}
      @verbose = opts[:verbose] || false
      discover_entry_points
      if entry_points.include?(:buckets)
        extend(ClientBucketMethods)
      end
      yield self if block_given?
    end

    # This method can be used to switch back-end cloud
    # for API instance using HTTP headers.
    # Options must include:
    # {
    #   :driver => 'rhevm|ec2|gogrid|...',
    #   :username => 'API key for backend',
    #   :password => 'API secret key for backend',
    # }
    # Optionally you can pass also :provider option to change
    # provider entry-point
    #
    # Example usage:
    # client = Deltacloud::new('url', 'username', 'password')
    # ...
    # client.with_config(:driver => 'ec2', :username => '', :password => '') do |ec2|
    #   ec2.realms
    # end
    #
    # Note: After this block finish client instance will be set back to default
    # state
    #
    # @param [Hash, opts] New provider configuration
    def with_config(opts, &block)
      api_instance = self.dup
      api_instance.use_driver(opts[:driver],
                             :username => opts[:username],
                             :password => opts[:password],
                             :provider => opts[:provider])
      yield api_instance if block_given?
      api_instance
    end

    def connect(&block)
      yield self
    end

    # Return API hostname
    def api_host; @api_uri.host ; end

    # Return API port
    def api_port; @api_uri.port ; end

    # Return API path
    def api_path; @api_uri.path ; end

    # Define methods based on 'rel' attribute in entry point
    # Two methods are declared: 'images' and 'image'
    def declare_entry_points_methods(entry_points)
      API.instance_eval do
        entry_points.keys.select {|k| [:instance_states].include?(k)==false }.each do |model|

          define_method model do |*args|
            request(:get, entry_points[model], args.first) do |response|
              base_object_collection(model, response)
            end
          end

          define_method :"#{model.to_s.singularize}" do |*args|
            request(:get, "#{entry_points[model]}/#{args[0]}") do |response|
              base_object(model, response)
            end
          end

          define_method :"fetch_#{model.to_s.singularize}" do |url|
            id = url.grep(/\/#{model}\/(.*)$/)
            self.send(model.to_s.singularize.to_sym, $1)
          end

      end

      #define methods for blobs:
      if(entry_points.include?(:buckets))
        define_method :"blob" do |*args|
            bucket = args[0]["bucket"]
            blob = args[0][:id]
            request(:get, "#{entry_points[:buckets]}/#{bucket}/#{blob}") do |response|
              base_object("blob", response)
            end
        end
      end

      end
    end

    def base_object_collection(model, response)
      Nokogiri::XML(response).xpath("#{model}/#{model.to_s.singularize}").collect do |item|
        base_object(model, item.to_s)
      end
    end

    # Add default attributes [id and href] to class
    def base_object(model, response)
      c = DeltaCloud.add_class("#{model}", DeltaCloud::guess_model_type(response))
      xml_to_class(c, Nokogiri::XML(response).xpath("#{model.to_s.singularize}").first)
    end

    # Convert XML response to defined Ruby Class
    def xml_to_class(base_object, item)

      return nil unless item

      params = {
          :id => item['id'],
          :url => item['href'],
          :name => item.name,
          :client => self
      }
      params.merge!({ :initial_state => (item/'state').text.sanitize }) if (item/'state').length > 0

      obj = base_object.new(params)
      # Traverse across XML document and deal with elements
      item.xpath('./*').each do |attribute|
        # Do a link for elements which are links to other REST models
        if self.entry_points.keys.include?(:"#{attribute.name}s")
          obj.add_link!(attribute.name, attribute['id']) && next unless (attribute.name == 'bucket' && item.name == 'blob')
        end

        # Do a HWP property for hardware profile properties
        if attribute.name == 'property'
          if attribute['value'] =~ /^(\d+)\.(\d+)$/
            obj.add_hwp_property!(attribute['name'], attribute, :float) && next
          else
            obj.add_hwp_property!(attribute['name'], attribute, :integer) && next
          end
        end

        # If there are actions, add they to ActionObject/StateFullObject
        if attribute.name == 'actions'
          (attribute/'link').each do |link|
            (obj.add_run_action!(item['id'], link) && next) if link[:rel] == 'run'
            obj.add_action_link!(item['id'], link)
          end && next
        end

        if attribute.name == 'mount'
          obj.add_link!("instance", (attribute/"./instance/@id").first.value)
          obj.add_text!("device", (attribute/"./device/@name").first.value)
          next
        end

        #deal with blob metadata
        if (attribute.name == 'user_metadata')
          meta = {}
          attribute.children.select {|x| x.name=="entry" }.each  do |element|
            value = element.content.gsub!(/(\n) +/,'')
            meta[element['key']] = value
          end
          obj.add_collection!(attribute.name, meta.inspect) && next
        end

        if (['public_addresses', 'private_addresses'].include? attribute.name)
          obj.add_addresses!(attribute.name, (attribute/'*')) && next
        end

        if ('authentication'.include? attribute.name)
          obj.add_authentication!(attribute[:type], (attribute/'*')) && next
        end

        # Deal with collections like public-addresses, private-addresses
        if (attribute/'./*').length > 0
          obj.add_collection!(attribute.name, (attribute/'*').collect { |value| value.text }) && next
        end

        #deal with blobs for buckets
        if(attribute.name == 'blob')
          obj.add_blob!(attribute.attributes['id'].value) && next
        end

        # Anything else is treaten as text object
        obj.add_text!(attribute.name, attribute.text.convert)
      end
      return obj
    end

    # Get /api and parse entry points
    def discover_entry_points
      return if discovered?
      request(:get, @api_uri.to_s) do |response|
        api_xml = Nokogiri::XML(response)
        @driver_name = api_xml.xpath('/api').first['driver']
        @api_version = api_xml.xpath('/api').first['version']

        api_xml.css("api > link").each do |entry_point|
          rel, href = entry_point['rel'].to_sym, entry_point['href']
          @entry_points.store(rel, href)

          entry_point.css("feature").each do |feature|
            @features[rel] ||= []
            @features[rel] << feature['name'].to_sym

          end
        end
      end
      declare_entry_points_methods(@entry_points)
    end

    # Generate create_* methods dynamically
    #
    def method_missing(name, *args)
      if name.to_s =~ /create_(\w+)/
        params = args[0] if args[0] and args[0].class.eql?(Hash)
        params ||= args[1] if args[1] and args[1].class.eql?(Hash)
        params ||= {}

        # FIXME: This fixes are related to Instance model and should be
        # replaced by 'native' parameter names

        params[:realm_id] ||= params[:realm] if params[:realm]
        params[:keyname] ||= params[:key_name] if params[:key_name]
        params[:user_data] = Base64::encode64(params[:user_data]) if params[:user_data]

        if params[:hardware_profile] and params[:hardware_profile].class.eql?(Hash)
          params[:hardware_profile].each do |k,v|
            params[:"hwp_#{k}"] ||= v
          end
        else
          params[:hwp_id] ||= params[:hardware_profile]
        end

        params[:image_id] ||= params[:image_id] || args[0] if args[0].class!=Hash

        obj = nil

        request(:post, entry_points[:"#{$1}s"], {}, params) do |response|
          obj = base_object(:"#{$1}", response)
          # All create calls must respond 201 HTTP code
          # to indicate that resource was created.
          handle_backend_error(response) if response.code!=201
          yield obj if block_given?
        end
        return obj
      end
      raise NoMethodError
    end

    def use_driver(driver, opts={})
      if driver
        @api_driver = driver 
        @driver_name = driver
        @features, @entry_points = {}, {}
        discover_entry_points
      end
      @username = opts[:username] if opts[:username]
      @password = opts[:password] if opts[:password]
      @api_provider = opts[:provider] if opts[:provider]
      return self
    end

    def use_config!(opts={})
      @api_uri = URI.parse(opts[:url]) if opts[:url]
      use_driver(opts[:driver], opts)
    end

    def extended_headers
      headers = {}
      headers["X-Deltacloud-Driver"] = @api_driver.to_s if @api_driver
      headers["X-Deltacloud-Provider"] = @api_provider.to_s if @api_provider
      headers
    end

    # Basic request method
    #
    def request(*args, &block)
      conf = {
        :method => (args[0] || 'get').to_sym,
        :path => (args[1]=~/^http/) ? args[1] : "#{api_uri.to_s}#{args[1]}",
        :query_args => args[2] || {},
        :form_data => args[3] || {},
        :timeout => args[4] || 45,
        :open_timeout => args[5] || 10
      }
      if conf[:query_args] != {}
        conf[:path] += '?' + URI.escape(conf[:query_args].collect{ |key, value| "#{key}=#{value}" }.join('&')).to_s
      end

      if conf[:method].eql?(:post)
        resource = RestClient::Resource.new(conf[:path], :open_timeout => conf[:open_timeout], :timeout => conf[:timeout])
        resource.send(:post, conf[:form_data], default_headers.merge(extended_headers)) do |response, request, block|
          handle_backend_error(response) if response.code.eql?(500)
          if response.respond_to?('body')
            yield response.body if block_given?
          else
            yield response.to_s if block_given?
          end
        end
      else
        resource = RestClient::Resource.new(conf[:path], :open_timeout => conf[:open_timeout], :timeout => conf[:timeout])
        resource.send(conf[:method], default_headers.merge(extended_headers)) do |response, request, block|
          handle_backend_error(response) if response.code.eql?(500)
          if conf[:method].eql?(:get) and [301, 302, 307].include? response.code
            response.follow_redirection(request) do |response, request, block|
              if response.respond_to?('body')
                yield response.body if block_given?
              else
                yield response.to_s if block_given?
              end
            end
          else
            if response.respond_to?('body')
              yield response.body if block_given?
            else
              yield response.to_s if block_given?
            end
          end
        end
      end
    end

    # Re-raise backend errors as on exception in client with message from
    # backend
    class BackendError < StandardError
      def initialize(opts={})
        @message = opts[:message]
      end
      def message
        @message
      end
    end

    def handle_backend_error(response)
      raise BackendError.new(:message => (Nokogiri::XML(response)/'error/message').text)
    end

    # Check if specified collection have wanted feature
    def feature?(collection, name)
      @features.has_key?(collection) && @features[collection].include?(name)
    end

    # List available instance states and transitions between them
    def instance_states
      states = []
      request(:get, entry_points[:instance_states]) do |response|
        Nokogiri::XML(response).xpath('states/state').each do |state_el|
          state = DeltaCloud::InstanceState::State.new(state_el['name'])
          state_el.xpath('transition').each do |transition_el|
            state.transitions << DeltaCloud::InstanceState::Transition.new(
              transition_el['to'],
              transition_el['action']
            )
          end
          states << state
        end
      end
      states
    end

    # Select instance state specified by name
    def instance_state(name)
      instance_states.select { |s| s.name.to_s.eql?(name.to_s) }.first
    end

    # Skip parsing /api when we already got entry points
    def discovered?
      true if @entry_points!={}
    end

    # This method will retrieve API documentation for given collection
    def documentation(collection, operation=nil)
      data = {}
      request(:get, "/docs/#{collection}") do |body|
        document = Nokogiri::XML(body)
        if operation
          data[:operation] = operation
          data[:description] = document.xpath('/docs/collection/operations/operation[@name = "'+operation+'"]/description').first.text.strip
          return false unless data[:description]
          data[:params] = []
          (document/"/docs/collection/operations/operation[@name='#{operation}']/parameter").each do |param|
            data[:params] << {
              :name => param['name'],
              :required => param['type'] == 'optional',
              :type => (param/'class').text
            }
          end
        else
          data[:description] = (document/'/docs/collection/description').text
          data[:collection] = collection
          data[:operations] = (document/"/docs/collection/operations/operation").collect{ |o| o['name'] }
        end
      end
      return Documentation.new(self, data)
    end

    private

    def default_headers
      # The linebreaks inserted every 60 characters in the Base64
      # encoded header cause problems under JRuby
      auth_header = "Basic "+Base64.encode64("#{@username}:#{@password}")
      auth_header.gsub!("\n", "")
      {
        :authorization => auth_header,
        :accept => "application/xml"
      }
    end

  end

end
