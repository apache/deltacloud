require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'MockDriver Buckets' do

  before do
    @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
  end

  it 'must throw error when wrong credentials for buckets' do
    Proc.new do
      @driver.backend.buckets(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

end
