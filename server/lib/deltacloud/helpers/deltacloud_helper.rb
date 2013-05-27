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

module Deltacloud::Helpers
  module Application

    def current_provider
      Thread.current[:provider] || ENV['API_PROVIDER'] || 'default'
    end

    def collections_to_json(collections)
      r = {
        :version => settings.version,
        :driver => driver_symbol,
        :provider => Thread.current[:provider] || ENV['API_PROVIDER'],
        :links => collections.map { |c|
          {
            :rel => c.collection_name,
            :href => self.send(:"#{c.collection_name}_url"),
            :features => c.features.select { |f| driver.class.has_feature?(c.collection_name, f.name) }.map { |f|
              f.operations.map { |o|
                { :name => f.name, :rel => o.name, :params => o.params_array, :constraints => constraints_hash_for(c.collection_name, f.name) }
              }
            }
          }
        }
      }
      r[:provider] ||= 'default'
      JSON::dump(:api => r)
    end

    def constraints_hash_for(collection_name, feature_name)
      driver.class.constraints(:collection => collection_name, :feature => feature_name).inject({}) { |r, v| r[v[0]]=v[1];r }
    end

    def request_headers
      env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
    end

    def auth_feature_name
      return 'key' if driver.class.has_feature?(:instances, :authentication_key)
      return 'password' if driver.class.has_feature?(:instances, :authentication_password)
    end

    def instance_action_method(action)
      action_method(action, Deltacloud::Rabbit::InstancesCollection)
    end

    def action_method(action, collection)
      http_method = collection.operation(action).http_method
      http_method || Deltacloud::Rabbit::BaseCollection.http_method_for(action)
    end

    def filter_all(model, opts={})
      begin
        @benchmark = Benchmark.measure { @elements = driver.send(model.to_sym, credentials, params) }
      rescue => e
        @exception = e
      end
      locals = opts[:check] ? {:elements => @elements, opts[:check]=>driver.respond_to?(opts[:check])} : {:elements => @elements}
      if @elements
        headers['X-Backend-Runtime'] = @benchmark.real.to_s
        instance_variable_set(:"@#{model}", @elements)
        respond_to do |format|
          format.html { haml :"#{model}/index", :locals => locals}
          format.xml  { haml :"#{model}/index", :locals => locals}
          format.json { JSON::dump({ model => @elements.map { |el| el.to_hash(self) }}) }
        end
      else
        report_error(@exception.respond_to?(:code) ? @exception.code : nil)
      end
    end

    def show(model, opts={})
      @benchmark = Benchmark.measure do
        @element = driver.send(model, credentials, { :id => params[:id]} )
      end
      headers['X-Backend-Runtime'] = @benchmark.real.to_s
      instance_variable_set("@#{model}", @element)
      #checks for methods in opts:
      locals = opts[:check] ? {model => @element, opts[:check]=>driver.respond_to?(opts[:check])} : {model => @element}
      if @element
        respond_to do |format|
          format.html { haml :"#{model.to_s.pluralize}/show", :locals=>locals}
          format.xml { haml :"#{model.to_s.pluralize}/show" , :locals=>locals}
          format.json { JSON::dump(model => @element.to_hash(self)) }
        end
      else
        report_error(404)
      end
    end

    # Log errors to the same logger as we use for logging requests
    def log
      Deltacloud::Exceptions.logger(Deltacloud.default_frontend.logger)
    end

    def report_error(code=nil, message=nil)

      if !code.nil?
        error = Deltacloud::Exceptions.exception_from_status(code, message || translate_error_code(code)[:message])
        message = error.message
      else
        error = request.env['sinatra.error'] || @exception
        code = error.respond_to?(:code) ? error.code : 500
        message = error.respond_to?(:message) ? error.message : translate_error_code(code)[:message]
      end

      response.status = code

      backtrace = (error.respond_to?(:backtrace) and !error.backtrace.nil?) ?
        "\n\n#{error.backtrace[0..20].join("\n")}\n\n" : ''

      if code.to_s =~ /5(\d+)/
        log.error(code.to_s) { "[#{error.class.to_s}] #{message}#{backtrace}" }
      end

      respond_to do |format|
        format.xml {  haml :"errors/common", :layout => false, :locals => { :err => error } }
        format.json { JSON::dump({ :code => code || error.code, :message => message, :error => error.class.name }) }
        format.html {
          begin
            haml :"errors/common", :layout => :error, :locals => { :err => error }
          rescue RuntimeError
            # If the HTML representation of error is missing, then try to report
            # it through XML
            @media_type=:xml
            haml :"errors/common", :layout => false
          end
        }
      end
    end

    def instance_action(name)
      unless original_instance = driver.instance(credentials, :id => params[:id])
        return report_error(403)
      end

      # If original instance doesn't include called action
      # return with 405 error (Method is not Allowed)
      unless driver.instance_actions_for(original_instance.state).include?(name.to_sym)
        return report_error(405)
      end

      @benchmark = Benchmark.measure do
        @instance = driver.send(:"#{name}_instance", credentials, params[:id])
      end

      headers['X-Backend-Runtime'] = @benchmark.real.to_s

      if name == :destroy
        response = respond_to do |format|
          format.html { redirect(instances_url) }
        end
        halt 204, response
      end

      unless @instance.class == Deltacloud::Instance
        redirect instance_url(params[:id])
      else
        response = respond_to do |format|
          format.xml { haml :"instances/show", :locals => { :instance => @instance } }
          format.html { haml :"instances/show", :locals => { :instance => @instance } }
          format.json { JSON::dump(@instance.to_hash(self)) }
        end
        halt 202, response
      end
    end

    def cdata(text = nil, &block)
      text ||= capture_haml(&block)
      "<![CDATA[#{text.strip}]]>"
    end

    def render_cdata(text)
      "<![CDATA[#{text.strip}]]>" unless text.nil?
    end

    def link_to_action(action, url, method)
      capture_haml do
        haml_tag :form, :method => :post, :action => url, :class => [:link, method], :'data-ajax' => 'false' do
          haml_tag :input, :type => :hidden, :name => '_method', :value => method
          haml_tag :button, :type => :submit, :'data-ajax' => 'false', :'data-inline' => "true" do
            haml_concat action
          end
        end
      end
    end

    def link_to_format(format)
      return unless request.env['REQUEST_URI']
      uri = request.env['REQUEST_URI']
      return if uri.include?('format=')
      uri += uri.include?('?') ? "&format=#{format}" : "?format=#{format}"
      capture_haml do
        haml_tag :a, :href => uri, :'data-ajax' => 'false', :'data-icon' => 'grid' do
          haml_concat format.to_s.upcase
        end
      end
    end

    def image_for_state(state)
      capture_haml do
        haml_tag :img, :src => "/images/#{state}" % state.downcase, :title => state
      end
    end

    # Reverse the entrypoints hash for a driver from drivers.yaml; note that
    # +d+ is a hash, not an actual driver object
    def driver_provider(d)
      result = {}
      if d[:entrypoints]
        d[:entrypoints].each do |kind, details|
          details.each do |prov, url|
            result[prov] ||= {}
            result[prov][kind] = url
          end
        end
      end
      result
    end

    def header(title, opts={}, &block)
      opts[:theme] ||= 'b'
      opts[:back] ||= 'true'
      capture_haml do
        haml_tag :div, :'data-role' => :header, :'data-theme' => opts[:theme], :'data-add-back-btn' => opts[:back] do
          haml_tag :a, :'data-rel' => :back do
            haml_concat "Back"
          end if opts[:back] == 'true'
          haml_tag :h1 do
            haml_concat title
          end
          block.call if block_given?
        end
      end
    end

    def subheader(title, opts={})
      opts[:theme] ||= 'a'
      capture_haml do
        haml_tag :div, :'data-role' => :header, :'data-theme' => opts[:theme] do
          haml_tag :p, :class => 'inner-right' do
            haml_concat title
          end
        end
      end
    end

    def translate_error_code(code)
      case code
      when 400; { :message => "Bad Request" }
      when 401; { :message => "Unauthorized" }
      when 403; { :message => "Forbidden" }
      when 404; { :message => "Not Found" }
      when 405; { :message => "Method Not Allowed" }
      when 406; { :message => "Not Acceptable" }
      when 409; { :message => "Resource Conflict" }
      when 500; { :message => "Internal Server Error" }
      when 502; { :message => "Backend Server Error" }
      when 504; { :message => "Gateway Timeout" }
      when 501; { :message => "Not Supported" }
      end
    end

    NEW_BLOB_FORM_ID = 'new_blob_form_d15cfd90' unless defined?(NEW_BLOB_FORM_ID)

    def new_blob_form_url(bucket)
      bucket_url(@bucket.name) + "/" + NEW_BLOB_FORM_ID
    end

    def format_hardware_property(prop)
      return "&empty;" unless prop
      u = hardware_property_unit(prop)
      case prop.kind
      when :range
        "#{prop.first} #{u} - #{prop.last} #{u} (default: #{prop.default} #{u})"
      when :enum
        prop.values.collect{ |v| "#{v} #{u}"}.join(', ') + " (default: #{prop.default} #{u})"
      else
        "#{prop.value} #{u}"
      end
    end

    def format_instance_profile(ip)
      o = ip.overrides.collect do |p, v|
        u = hardware_property_unit(p)
        "#{p} = #{v} #{u}"
      end
      if o.empty?
        nil
      else
        "with #{o.join(", ")}"
      end
    end

    def order_hardware_profiles(profiles)
      #have to deal with opaque hardware profiles
      uncomparables = profiles.select{|x| x.cpu.nil? or x.memory.nil? }
      if uncomparables.empty?
        profiles.sort_by{|a| [a.cpu.default, a.memory.default] }
      else
        (profiles - uncomparables).sort_by{|a| [a.cpu.default, a.memory.default] } + uncomparables
      end
    end

    def additional_features_for?(collection_name, apart_from = [])
      features_arr = (driver.class.features[collection_name.to_sym] || [] )  - apart_from
      not features_arr.empty?
    end

    module SinatraHelper

      def new_route_for(route, &block)
        get '/%s/new' % route.to_s do
          @opts = {}
          instance_eval(&block) if block_given?
          respond_to do |format|
            format.html do
              haml :"#{route}/new", :locals => @opts
            end
          end
        end
      end

      def check_features(opts={})
        Sinatra::Rabbit.set :check_features, opts[:for]
      end

    end

    def Application.included(klass)
      klass.extend SinatraHelper
    end

    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }

    def h(s)
      s.to_s.gsub(/[&"><]/n) { |special| HTML_ESCAPE[special] }
    end

    def bt(trace)
      return [] unless trace
      return trace.join("\n") if params['fulltrace']
      app_path = File::expand_path("../../..", __FILE__)
      dots = false
      trace = trace.map { |t| t.match(%r{^#{app_path}(.*)$}) ? "$app#{$1}" : "..." }.select do |t|
        if t == "..."
          keep = ! dots
          dots = true
        else
          keep = true
          dots = false
        end
        keep
      end
      "[\nAbbreviated trace\n   pass fulltrace=1 as query param to see everything\n  $app = #{app_path}\n]\n" + trace.join("\n")
    end

    private
    def hardware_property_unit(prop)
      u = ::Deltacloud::HardwareProfile::unit(prop)
      u = "" if ["label", "count"].include?(u)
      u = "vcpus" if prop == :cpu
      u
    end



  end
end
