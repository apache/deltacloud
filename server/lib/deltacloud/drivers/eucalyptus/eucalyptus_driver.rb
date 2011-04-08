# Copyright (C) 2009, 2010  Red Hat, Inc.
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
#

require 'deltacloud/drivers/ec2/ec2_driver.rb'

module Deltacloud
  module Drivers
    module Eucalyptus
      class EucalyptusDriver < EC2::EC2Driver

        def supported_collections
          DEFAULT_COLLECTIONS + [ :keys, :buckets ]
        end

        feature :instances, :user_data
        feature :instances, :authentication_key
        feature :instances, :security_group
        feature :instances, :instance_count
        feature :images, :owner_id

        define_hardware_profile('m1.small') do
          cpu                1
          memory             128
          storage            2
          architecture       'x86_64'
        end

        define_hardware_profile('c1.medium') do
          cpu                1
          memory             256
          storage            5
          architecture       'x86_64'
        end

        define_hardware_profile('m1.large') do
          cpu                2
          memory             512
          storage            10
          architecture       'x86_64'
        end

        define_hardware_profile('m1.xlarge') do
          cpu                2
          memory             1024
          storage            20
          architecture       'x86_64'
        end

        define_hardware_profile('c1.xlarge') do
          cpu                4
          memory             2048
          storage            20
          architecture       'x86_64'
        end

        def self.instance_state_machine
          EC2::EC2Driver.instance_state_machine
        end

        def instance_state_machine
          self.class.instance_state_machine
        end

        def default_image_owner
          "self"
        end

        def default_image_type
          nil
        end

        def tagging?
          false
        end

        def tag_instance(credentials, instance, name)
          # dummy
        end

        def untag_instance(credentials, instance_id)
          # dummy
        end

        # because load balancer is not on the supported_collections,
        # the following methods shouldn't be called.
        def load_balancer(credentials, opts={})
          raise Deltacloud::BackendError.new(500, "Loadbalancer",
                  "Loadbalancer not supported in Eucalyptus", "")
        end

        def load_balancers(credentials, opts=nil)
          raise Deltacloud::BackendError.new(500, "Loadbalancer",
                  "Loadbalancer not supported in Eucalyptus", "")
        end

        def create_load_balancer(credentials, opts={})
          raise Deltacloud::BackendError.new(500, "Loadbalancer",
                  "Loadbalancer not supported in Eucalyptus", "")
        end

        def destroy_load_balancer(credentials, id)
          raise Deltacloud::BackendError.new(500, "Loadbalancer",
                  "Loadbalancer not supported in Eucalyptus", "")
        end

        def lb_register_instance(credentials, opts={})
          raise Deltacloud::BackendError.new(500, "Loadbalancer",
                  "Loadbalancer not supported in Eucalyptus", "")
        end

        def lb_unregister_instance(credentials, opts={})
          raise Deltacloud::BackendError.new(500, "Loadbalancer",
                  "Loadbalancer not supported in Eucalyptus", "")
        end

        def new_client(credentials, type = :ec2)
          klass = case type
                  when :ec2 then Aws::Ec2
                  when :s3 then Aws::S3
                  when :elb then raise Deltacloud::BackendError.new(500,
                                         "Loadbalancer",
                          "Loadbalancer not supported in Eucalyptus", "")
                  end
          klass.new(credentials.user, credentials.password, eucalyptus_endpoint)
        end

        def eucalyptus_endpoint
          endpoint = (Thread.current[:provider] || ENV['API_PROVIDER'])
          if endpoint && (endpoint.include?('ec2') || endpoint.include?('s3'))   # example endpoint: 'ec2=192.168.1.1; s3=192.168.1.2'
	     default_port=8773
	     endpoint.split(';').each do |svc_addr|
	        addr = svc_addr.sub('ec2=','').sub('s3=','').strip
                if addr.include?(':')
                   host = addr.split(':')[0]
                   port = addr.split(':')[1]
                else
                   host = addr
	           port = default_port 
                end
                if svc_addr.include?('ec2')
	           ENV['EC2_URL'] = "http://#{host}:#{port}/services/Eucalyptus"
                elsif svc_addr.include?('s3')
                   ENV['S3_URL'] = "http://#{host}:#{port}/services/Walrus" 
	        end
             end 
             {}
          else
            #EC2_URL/S3_URL env variable will be used by AWS
            {:connection_mode => :per_thread}
          end
        end
      end
    end
  end
end
