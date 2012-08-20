require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Ec2Driver Realms' do

  before do
    @driver = Deltacloud::new(:ec2, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.realms(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::ExceptionHandler::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of realms' do
    @driver.realms.wont_be_empty
    @driver.realms.first.must_be_kind_of Realm
  end

  it 'must allow to filter realms' do
    @driver.realms(:id => 'us-east-1a').wont_be_empty
    @driver.realms(:id => 'us-east-1a').must_be_kind_of Array
    @driver.realms(:id => 'us-east-1a').size.must_equal 1
    @driver.realms(:id => 'us-east-1a').first.id.must_equal 'us-east-1a'
    @driver.realms(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single realm' do
    @driver.realm(:id => 'us-east-1a').wont_be_nil
    @driver.realm(:id => 'us-east-1a').must_be_kind_of Realm
    @driver.realm(:id => 'us-east-1b').id.must_equal 'us-east-1b'
    @driver.realm(:id => 'unknown').must_be_nil
  end

  it 'must list VPC subnets as realms' do
    id = "#{@@subnet[:availability_zone]}:#{@@subnet[:subnet_id]}"
    @driver.realms.find { |r| r.id == id }.wont_be_nil
  end

end
