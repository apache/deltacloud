# Warning: RightHttpConnection has to be required before WebMock is required !!!
# Lets require that:
#require 'right_http_connection'
#require 'vcr'

require_relative '../../test_helper.rb'
#require_relative '../../../lib/deltacloud/drivers/ec2/ec2_driver'

def credentials
  Deltacloud::Test::config.credentials('ec2')
end