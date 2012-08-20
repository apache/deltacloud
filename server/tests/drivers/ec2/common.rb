# Warning: RightHttpConnection has to be required before WebMock is required !!!
# Lets require that:
require 'right_http_connection'
require 'vcr'

require_relative '../../test_helper.rb'
require_relative '../../../lib/deltacloud/drivers/ec2/ec2_driver'

def credentials
  Deltacloud::Test::config.credentials('ec2')
end

# Monkey patch EC2 driver to return a client
class Deltacloud::Drivers::Ec2::Ec2Driver
  def client(credentials)
    new_client(credentials)
  end
end

# Configure VCR
VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  matcher = VCR.request_matchers.uri_without_param("AWSAccessKeyId",
                                                   "Signature", "Timestamp")
  c.register_request_matcher(:ec2_matcher, &matcher)
  c.default_cassette_options = { :record => :none, :match_requests_on => [:method, :ec2_matcher] }
end

# Setup resources we need for the tests
def create_resources
  VCR.use_cassette "create_resources" do
    driver = Deltacloud::new(:ec2, credentials)
    @@ec2 = driver.client
    @@vpc = @@ec2.create_vpc("172.16.0.0/16").first
    @@subnet = @@ec2.create_subnet(@@vpc[:vpc_id], "172.16.3.0/24", "us-east-1b").first
  end
end

def destroy_resources
  VCR.use_cassette "destroy_resources" do
    @@ec2.delete_subnet(@@subnet[:subnet_id]) if @@subnet
    @@ec2.delete_vpc(@@vpc[:vpc_id]) if @@vpc
  end
end

MiniTest::Unit::after_tests { destroy_resources }

create_resources
