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

  require_relative '../core_ext.rb'
  require_relative './exceptions.rb'
  require_relative './features.rb'
  require_relative './cimi_features.rb'
  require_relative '../models/state_machine.rb'

  class BaseDriver

    include Exceptions

    STATE_MACHINE_OPTS = {
      :all_states => [:start, :pending, :running, :stopping, :stopped, :finish],
      :all_actions => [:create, :reboot, :stop, :start, :destroy]
    } unless defined?(STATE_MACHINE_OPTS)

    def self.driver_name
      name.split('::').last.gsub('Driver', '').downcase
    end

    def self.features
      @features ||= {}
    end

    def self.feature(collection, feature_name)
      return if has_feature?(collection, feature_name)
      constraints[collection] ||= {}
      constraints[collection][feature_name] ||= {}
      constraints[collection][feature_name].merge!(yield) if block_given?
      features[collection] ||= []
      features[collection] << feature_name
    end

    def self.constraints(opts={})
      if opts[:collection] and opts[:feature]
        return [] unless @constraints.has_key? opts[:collection]
        return @constraints[opts[:collection]][opts[:feature]]
      end
      @constraints ||= {}
    end

    def self.has_feature?(collection, feature_name)
      features.has_key?(collection) and features[collection].include?(feature_name)
    end

    def has_feature?(collection, feature_name)
      self.class.has_feature?(collection, feature_name)
    end

    def name
      self.class.name.split('::').last.gsub('Driver', '').downcase
    end

    def self.define_hardware_profile(profile_id, &block)
      @hardware_profiles ||= []
      hw_profile = @hardware_profiles.find{|e| e.id == profile_id }
      return if hw_profile
      hw_profile = ::Deltacloud::HardwareProfile.new(profile_id, &block )
      @hardware_profiles << hw_profile
      hw_profile.params
    end

    def self.hardware_profiles
      @hardware_profiles ||= []
      @hardware_profiles
    end

    def hardware_profiles(credentials, opts = {})
      results = self.class.hardware_profiles
      filter_hardware_profiles(results, opts)
    end

    def hardware_profile(credentials, profile_id)
      profile_id = profile_id[:id] if profile_id.kind_of? Hash
      hardware_profiles(credentials, :id => profile_id).first
    end

    def filter_hardware_profiles(profiles, opts)
      if opts
        if v = opts[:architecture]
          profiles = profiles.select { |hwp| hwp.include?(:architecture, v) }
        end
        if v = opts[:id]
          profiles = profiles.select { |hwp| hwp.id == v }
        end
      end
      profiles
    end

    def find_hardware_profile(credentials, profile_id, image_id)
      hwp = nil
      if profile_id
        unless hwp = hardware_profile(credentials, profile_id)
          raise Exceptions.exception_from_status(400, "Hardware profile '#{profile_id}' does not exists.")
        end
      else
        unless image = image(credentials, :id=>image_id)
          raise Exceptions.exception_from_status(400, "Image #{image_id} does not exists.")
        end
        hwp = hardware_profiles(credentials, :architecture => image.architecture).first
      end
      return hwp
    end

    def self.define_instance_states(&block)
      machine = ::Deltacloud::StateMachine.new(STATE_MACHINE_OPTS, &block)
      @instance_state_machine = machine
    end

    def self.instance_state_machine
      @instance_state_machine
    end

    def instance_state_machine
      self.class.instance_state_machine
    end

    def instance_actions_for(state)
      actions = []
      states = instance_state_machine.states()
      current_state = states.find{|e| e.name == state.underscore.to_sym }
      if ( current_state )
        actions = current_state.transitions.collect{|e|e.action}
        actions.reject!{|e| e.nil?}
      end
      actions
    end

    def has_capability?(method)
      method = (RUBY_VERSION =~ /^1\.9/) ? method : method.to_s
      # Prevent has_capability fail when driver is inherited from another
      # driver, like Eucalyptus
      superclass_methods = self.class.superclass.name == 'Deltacloud::BaseDriver' ?
        self.class.superclass.instance_methods : []
      (self.class.instance_methods - superclass_methods).include? method
    end

    def supported_collections(credentials)
      collection_arr = []
      Deltacloud::Collections.deltacloud_modules.each do |m|
        m.collections.each do |c|
          # Get the required capability for the :index operation (like 'realms' or 'instance_state_machine')
          index_operation_capability = c.operation(:index).required_capability
          # Then use this capability to check if the 'capability' lambda defined
          # for the Sinatra::Base class evaluate to 'true'
          next if m.settings.respond_to?(:capability) and !m.settings.capability(index_operation_capability)
          yield c if block_given?
          collection_arr << c
        end
      end
      collection_arr
    end


    ## Capabilities
    # The rabbit dsl supports declaring a capability that is required
    # in the backend driver for the call to succeed. A driver can
    # provide a capability by implementing the method with the same
    # name as the capability. Below is a list of the capabilities as
    # the expected method signatures.
    #
    # Following the capability list are the resource member show
    # methods. They each require that the corresponding collection
    # method be defined
    #
    # TODO: standardize all of these to the same signature (credentials, opts)
    #
    # def realms(credentials, opts=nil)
    #
    # def images(credentials, ops)
    #
    # def instances(credentials, ops)
    # def create_instance(credentials, image_id, opts)
    # def start_instance(credentials, id)
    # def stop_instance(credentials, id)
    # def reboot_instance(credentials, id)
    #
    # def storage_volumes(credentials, ops)
    #
    # def storage_snapshots(credentials, ops)
    #
    # def buckets(credentials, opts = nil)
    # def create_bucket(credentials, name, opts=nil)
    # def delete_bucket(credentials, name, opts=nil)
    #
    # def blobs(credentials, opts = nil)
    # def blob_data(credentials, bucket_id, blob_id, opts)
    # def create_blob(credentials, bucket_id, blob_id, blob_data, opts=nil)
    # def delete_blob(credentials, bucket_id, blob_id, opts=nil)
    #
    # def keys(credentials, opts)
    # def create_key(credentials, opts)
    # def destroy_key(credentials, opts)
    #
    # def firewalls(credentials, opts)
    # def create_firewall(credentials, opts)
    # def delete_firewall(credentials, opts)
    # def create_firewall_rule(credentials, opts)
    # def delete_firewall_rule(credentials, opts)
    # def providers(credentials)
    def realm(credentials, opts)
      realms = realms(credentials, opts).first if has_capability?(:realms)
    end

    def image(credentials, opts)
      images(credentials, opts).first if has_capability?(:images)
    end

    def instance(credentials, opts)
      instances(credentials, opts).first if has_capability?(:instances)
    end

    def storage_volume(credentials, opts)
      storage_volumes(credentials, opts).first if has_capability?(:storage_volumes)
    end

    def storage_snapshot(credentials, opts)
      storage_snapshots(credentials, opts).first if has_capability?(:storage_snapshots)
    end

    def bucket(credentials, opts = {})
      #list of objects within bucket
      buckets(credentials, opts).first if has_capability?(:buckets)
    end

    def blob(credentials, opts = {})
      blobs(credentials, opts).first if has_capability?(:blobs)
    end

    def key(credentials, opts=nil)
      keys(credentials, opts).first if has_capability?(:keys)
    end

    def firewall(credentials, opts={})
      firewalls(credentials, opts).first if has_capability?(:firewalls)
    end

    def address(credentials, opts={})
      addresses(credentials, opts).first if has_capability?(:addresses)
    end


    MEMBER_SHOW_METHODS = [ :realm, :image, :instance, :storage_volume, :bucket, :blob,
                            :key, :firewall ] unless defined?(MEMBER_SHOW_METHODS)

    def filter_on(collection, attribute, opts)
      return collection if opts.nil?
      return collection if opts[attribute].nil?
      filter = opts[attribute]
      if ( filter.is_a?( Array ) )
        return collection.select{|e| filter.include?( e.send(attribute) ) }
      else
        return collection.select{|e| filter == e.send(attribute) }
      end
    end

    def catched_exceptions_list
      { :error => [], :auth => [], :glob => [] }
    end

    def api_provider
      Thread.current[:provider] || ENV['API_PROVIDER']
    end

    # Return an array of the providers statically configured
    # in the driver's YAML file
    def configured_providers
      []
    end
  end

end
