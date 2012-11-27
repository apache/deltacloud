require 'rubygems'
require 'minitest/autorun'
require 'require_relative' if RUBY_VERSION < '1.9'
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

  it 'can create a new bucket' do
    bucket_name = "mini_test_mock_bucket_name"
    bucket = @driver.create_bucket(bucket_name)
    bucket.id.wont_be_nil
    bucket.name.must_equal bucket_name
    bucket.size.must_equal "0"
    bucket.blob_list.must_be_empty
  end

end
