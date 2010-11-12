require 'deltacloud/method_serializer'

# Create 'mock' version of original driver client/gem:

module Mock

  class S3 < RightAws::S3
    include MethodSerializer::Cache

    def self.cached_methods
      [
        :buckets
      ]
    end

    MethodSerializer::Cache::wrap_methods(self, :cache_dir => File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'tests', 'ec2', 'support'))
  end

  class ELB < AWS::ELB::Base
    include MethodSerializer::Cache

    def self.cached_methods
      [
        :describe_load_balancers
      ]
    end

    MethodSerializer::Cache::wrap_methods(self, :cache_dir => File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'tests', 'ec2', 'support'))

  end

  class EC2 < AWS::EC2::Base

    include MethodSerializer::Cache

    def self.cached_methods
      [
        :describe_images,
        :describe_availability_zones,
        :describe_keypairs,
        :create_keypair,
        :run_instances,
        :describe_instances,
        :reboot_instances,
        :terminate_instances,
        :delete_keypair
      ]
    end

    MethodSerializer::Cache::wrap_methods(self, :cache_dir => File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'tests', 'ec2', 'support'))
  end
end


# Replace original client with mock client
Deltacloud::Drivers::EC2::EC2Driver.class_eval do
  alias_method :original_new_client, :new_client
  alias_method :original_s3_client, :s3_client

  def new_client(credentials, provider = :ec2)
    if provider == :elb
      Mock::ELB.new(
        :access_key_id => credentials.user,
        :secret_access_key => credentials.password
      )
    else
      Mock::EC2.new(
        :access_key_id => credentials.user,
        :secret_access_key => credentials.password
      )
    end
  end

  def s3_client(credentials)
    Mock::S3.new(credentials.user, credentials.password)
  end

end
