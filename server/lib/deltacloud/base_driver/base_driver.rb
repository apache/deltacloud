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

require 'lib/deltacloud/base_driver/exceptions'

module Deltacloud

  class BaseDriver

    include ExceptionHandler

    def self.exceptions(&block)
      ExceptionHandler::exceptions(&block)
    end

    def self.define_hardware_profile(name,&block)
      @hardware_profiles ||= []
      hw_profile = @hardware_profiles.find{|e| e.name == name}
      return if hw_profile
      hw_profile = ::Deltacloud::HardwareProfile.new( name, &block )
      @hardware_profiles << hw_profile
      hw_params = hw_profile.params
      unless hw_params.empty?
        feature :instances, :hardware_profiles do
          decl.operation(:create) { add_params(hw_params) }
        end
      end
    end

    def self.hardware_profiles
      @hardware_profiles ||= []
      @hardware_profiles
    end

    def hardware_profiles(credentials, opts = nil)
      results = self.class.hardware_profiles
      filter_hardware_profiles(results, opts)
    end

    def hardware_profile(credentials, name)
      hardware_profiles(credentials, :id => name).first
    end

    def filter_hardware_profiles(profiles, opts)
      if opts
        if v = opts[:architecture]
          profiles = profiles.select { |hwp| hwp.include?(:architecture, v) }
        end
        # As a request param, we call 'name' 'id'
        if v = opts[:id]
          profiles = profiles.select { |hwp| hwp.name == v }
        end
      end
      profiles
    end

    def find_hardware_profile(credentials, name, image_id)
      hwp = nil
      if name
        unless hwp = hardware_profiles(credentials, :id => name).first
          raise BackendError.new(400, "bad-hardware-profile-name",
            "Hardware profile '#{name}' does not exist", nil)
        end
      else
        unless image = image(credentials, :id=>image_id)
          raise BackendError.new(400, "bad-image-id",
              "Image with ID '#{image_id}' does not exist", nil)
        end
        hwp = hardware_profiles(credentials,
                                :architecture=>image.architecture).first
      end
      return hwp
    end

    def self.define_instance_states(&block)
      machine = ::Deltacloud::StateMachine.new(&block)
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
      state_key = state.downcase.to_sym
      states = instance_state_machine.states()
      current_state = states.find{|e| e.name == state.underscore.to_sym }
      if ( current_state )
        actions = current_state.transitions.collect{|e|e.action}
        actions.reject!{|e| e.nil?}
      end
      actions
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

    MEMBER_SHOW_METHODS =
      [ :realm, :image, :instance, :storage_volume, :bucket, :blob, :key ]

    def has_capability?(capability)
      if MEMBER_SHOW_METHODS.include?(capability.to_sym)
        has_capability?(capability.to_s.pluralize)
      else
        respond_to?(capability)
      end
    end


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

    def supported_collections
      DEFAULT_COLLECTIONS
    end

    def has_collection?(collection)
      supported_collections.include?(collection)
    end

    def catched_exceptions_list
      { :error => [], :auth => [], :glob => [] }
    end

  end

end
