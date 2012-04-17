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
  module InstanceFeatures

    def self.included(k)
      current_features = features
      k.instance_eval do
        features(&current_features)
      end
    end

    def self.features(&block)
      block_given? ? @features = block : @features || Proc.new{}
    end

    features do

      feature :user_name, :for => :instances do
        description "Allow to set user-defined name for the instance"
        operation :create do
          param :name, :string, :optional
        end
      end

      feature :user_data, :for => :instances do
        description "Allow to pass user-defined data into the instance"
        operation :create do
          param :user_data, :string, :optional
        end
      end

      feature :user_iso, :for => :instances do
        description  "Base64 encoded gzipped ISO file will be accessible as CD-ROM drive in instance"
        operation :create do
          param :user_iso, :string, :optional
        end
      end

      feature :firewalls, :for => :instances do
        description "Put instance in one or more firewalls (security groups) on launch"
        operation :create do
          param :firewalls, :array, :optional, nil, "Array of firewall ID strings"
          "Array of firewall (security group) id"
        end
      end

      feature :authentication_key, :for => :instances do
        operation :create do
          param :keyname, :string,  :optional, [], "Key authentification method"
        end
        operation :show do
        end
      end

      feature :authentication_password, :for => :instances do
        operation :create do
          param :password, :string, :optional
        end
      end

      feature :hardware_profiles, :for => :instances do
        description "Size instances according to changes to a hardware profile"
        # The parameters are filled in from the hardware profiles
      end

      feature :register_to_load_balancer, :for => :instances do
        description "Register instance to load balancer"
        operation :create do
          param :load_balancer_id, :string, :optional
        end
      end

      feature :instance_count, :for => :instances do
        description "Number of instances to be launch with at once"
        operation :create do
          param :instance_count,  :string,  :optional
        end
      end

      feature :attach_snapshot, :for => :instances do
        description "Attach an snapshot to instance on create"
        operation :create do
          param :snapshot_id,  :string,  :optional
          param :device_name,  :string,  :optional
        end
      end

      feature :sandboxing, :for => :instances do
        description "Allow lanuching sandbox images"
        operation :create do
          param :sandbox, :string,  :optional
        end
      end
    end

  end
end
