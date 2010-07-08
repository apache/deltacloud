require 'deltacloud/method_serializer'

# Create 'mock' version of original driver client/gem:

module Mock
  class EC2 < AWS::EC2::Base

    include MethodSerializer::Cache

    def self.cached_methods
      [
        :describe_images,
        :describe_availability_zones,
        :run_instances,
        :describe_instances,
        :reboot_instances,
        :terminate_instances
      ]
    end

    MethodSerializer::Cache::wrap_methods(self, :cache_dir => File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'tests', 'ec2', 'support'))
  end
end


# Replace original client with mock client
Deltacloud::Drivers::EC2::EC2Driver.class_eval do
  alias_method :original_new_client, :new_client

  def new_client(credentials, opts={})
    Mock::EC2.new(
      :access_key_id => credentials.user,
      :secret_access_key => credentials.password
    )
  end

end
