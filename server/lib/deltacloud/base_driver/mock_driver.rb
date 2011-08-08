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

require 'deltacloud/method_serializer'

# Create 'mock' version of original driver client/gem:

# Initialize driver and include Deltacloud
include Deltacloud
driver

module Mock

  class Ec2 < Aws::Ec2

    include MethodSerializer::Cache

    def self.cached_methods
      [
        :describe_images,
        :describe_images_by_owner,
        :describe_availability_zones,
        :launch_instances,
        :describe_instances,
        :reboot_instances,
        :create_tag,
        :delete_tag,
        :describe_tags,
        :terminate_instances,
        :describe_key_pairs,
        :create_key_pair,
        :delete_key_pair,
        :create_volume,
        :get_console_output,
        :describe_volumes,
        :delete_volume,
        :attach_volume,
        :detach_volume,
        :describe_snapshots,
        :associate_address,
        :try_create_snapshot,
      ]
    end

    MethodSerializer::Cache::wrap_methods(self, :cache_dir => File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'tests', 'ec2', 'support'))
  end

end


# Replace original client with mock client
Deltacloud::Drivers::EC2::EC2Driver.class_eval do
  alias_method :original_new_client, :new_client

  def new_client(credentials, provider = :ec2)
    auth_credentials = { :access_key_id => credentials.user, :secret_access_key => credentials.password}
    if provider == :elb
      Mock::ELB.new(auth_credentials)
    elsif provider == :s3
      Mock::S3.new(auth_credentials)
    else
      Mock::Ec2.new(auth_credentials[:access_key_id], auth_credentials[:secret_access_key])
    end
  end

end
