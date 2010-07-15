#
# Copyright (C) 2009  Red Hat, Inc.
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

  class AuthException < Exception
  end

  class BackendError < StandardError
    attr_reader :code, :cause, :details
    def initialize(code, cause, message, details)
      super(message)
      @code = code
      @cause = cause
      @details = details
    end
  end

  class BaseDriver

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
      hardware_profiles(credentials, :name => name).first
    end

    def filter_hardware_profiles(profiles, opts)
      if opts
        if v = opts[:architecture]
          profiles = profiles.select { |hwp| hwp.include?(:architecture, v) }
        end
        if v = opts[:name]
          profiles = profiles.select { |hwp| hwp.name == v }
        end
      end
      profiles
    end

    def find_hardware_profile(credentials, name, image_id)
      hwp = nil
      if name
        unless hwp = hardware_profiles(credentials, :name => name).first
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

    def realm(credentials, opts)
      realms = realms(credentials, opts)
      return realms.first unless realms.empty?
      nil
    end

    def realms(credentials, opts=nil)
      []
    end

    def image(credentials, opts)
      images = images(credentials, opts)
      return images.first unless images.empty?
      nil
    end

    def images(credentials, ops)
      []
    end

    def instance(credentials, opts)
      instances = instances(credentials, opts)
      return instances.first unless instances.empty?
      nil
    end

    def instances(credentials, ops)
      []
    end

    def create_instance(credentials, image_id, opts)
    end
    def start_instance(credentials, id)
    end
    def stop_instance(credentials, id)
    end
    def reboot_instance(credentials, id)
    end

    def storage_volume(credentials, opts)
      volumes = storage_volumes(credentials, opts)
      return volumes.first unless volumes.empty?
      nil
    end

    def storage_volumes(credentials, ops)
      []
    end

    def storage_snapshot(credentials, opts)
      snapshots = storage_snapshots(credentials, opts)
      return snapshots.first unless snapshots.empty?
      nil
    end

    def storage_snapshots(credentials, ops)
      []
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
      return true if self.supported_collections.include?(collection)
      return false
    end

  end

end
