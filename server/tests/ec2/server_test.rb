require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative './common.rb'

describe Deltacloud::EC2::API do

  before do
    def app; Deltacloud::EC2::API; end
  end

  it 'has the config set property' do
    Deltacloud::config[:ec2].must_be_kind_of Deltacloud::Server
    Deltacloud[:ec2].root_url.must_equal '/ec2'
  end

  it 'must do a redirection when no Action parameter' do
    get root_url
    status.must_equal 301
    headers['Location'].wont_be_empty
    headers['Location'].must_equal 'http://example.org/ec2'
  end

  it 'must set the Connection header to close' do
    get root_url
    headers['Connection'].must_equal 'close'
  end

  it 'must advertise current API version in response headers' do
    get root_url
    headers['Server'].must_equal 'Apache-Deltacloud-EC2/2012-04-01'
  end

  it 'must return EC2 exception when unknown action' do
    get root_url + '?Action=UnknownActionTest'
    xml.root.name.must_equal 'Response'
    (xml/'Response/Errors/Code').first.text.strip.must_equal 'InvalidAction'
  end

  it 'must return EC2 exception when authentication failed' do
    authorize 'unknownuser', 'password'
    get root_url + '?Action=DescribeAvailabilityZones'
    status.must_equal 401
  end

end
