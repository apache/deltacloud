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
          DEFAULT_COLLECTIONS + [ :keys, :buckets, :addresses, :firewalls ]
        end

        feature :instances, :user_data
        feature :instances, :authentication_key
        feature :instances, :firewalls
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

	# override EC2 implementation; Eucalyptus implements the older definition of EC2 security group;
	# http://docs.amazonwebservices.com/AWSEC2/2009-07-15/APIReference/index.html?ApiReference-query-AuthorizeSecurityGroupIngress.html
        # if the rule specifies a source group, port&protocol will be ignored. And source group and cidr range can't be mixed in a request
        def create_firewall_rule(credentials, opts={})
        # only either source groups or cidr IP range can be given, not both;
          if !(opts['groups'].nil?) && opts['groups'].length>0
            ec2 = new_client(credentials)
            opts['groups'].each do |group,owner|
              safely do
                ec2.authorize_security_group_named_ingress(opts['id'], owner, group)
              end
            end
          elsif !(opts['addresses'].nil?) && opts['addresses'].length>0
            ec2 = new_client(credentials)
            opts['addresses'].each do |ip|
              ec2.authorize_security_group_IP_ingress(opts['id'], opts['port_from'], opts['port_to'], opts['protocol'], ip)
            end
          end
        end

        def delete_firewall_rule(credentials, opts={})
          ec2 = new_client(credentials)
          firewall = opts[:firewall]
          protocol, from_port, to_port, addresses, groups = firewall_rule_params(opts[:rule_id])
          unless groups.nil?
            groups.each_index do |i|
              ec2.revoke_security_group_named_ingress(firewall, groups[i]['owner'], groups[i]['group_name'])
            end
          end
          unless addresses.nil?
            addresses.each do |ip|
              ec2.revoke_security_group_IP_ingress(firewall, from_port, to_port, protocol, ip )
            end
          end
        end

        def new_client(credentials, type = :ec2)
          klass = case type
                  when :ec2 then Aws::Ec2
                  when :s3 then Aws::S3
                  when :elb then raise Deltacloud::BackendError.new(500,
                                         "Loadbalancer",
                          "Loadbalancer not supported in Eucalyptus", "")
                  end
          klass.new(credentials.user, credentials.password,
                    endpoint_for_service(type))
        end

        SERVICE_STUBS = {
          "ec2" => "/services/Eucalyptus",
          "s3" => "/services/Walrus"
        }

        DEFAULT_PORT = 8773

        def endpoint_for_service(service)
          service = service.to_s
          endpoint = api_provider
          if endpoint && endpoint.include?(service)
            # example endpoint: 'ec2=192.168.1.1; s3=192.168.1.2'
            addr = Hash[endpoint.split(";").map { |svc| svc.strip.split("=") }][service]
            host = addr.split(':')[0]
            port = addr.split(':')[1] || DEFAULT_PORT
            stub = SERVICE_STUBS[service]
            { :endpoint_url => "http://#{host}:#{port}#{stub}",
              :connection_mode => :per_thread }
          else
            #EC2_URL/S3_URL env variable will be used by AWS
            { :connection_mode => :per_thread }
          end
        end
      end
    end
  end
end
