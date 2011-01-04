require 'deltacloud/method_serializer'

# Create 'mock' version of original driver client/gem:

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
        :terminate_instances,
        :describe_key_pairs,
        :create_key_pair,
        :delete_key_pair,
        :create_volume,
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
