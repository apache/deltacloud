require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'api.rb')
require_relative 'common.rb'

describe 'Ec2Driver Buckets' do

  def credentials
  {
    :user => "AKIAJATNOR5HKG3FK27Q",
    :password => "dPe47rAlKhlBdTYNbL4ZsMthDga08vEL9d3MS5UO"
  }
  end

  before do
    @driver = Deltacloud::new(:ec2, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials for buckets' do
    Proc.new do
      @driver.backend.buckets(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end


  it 'must handle us-east buckets from other regions' do
    #create us-east bucket:
    bucket = @driver.create_bucket("deltacloud-unit-test-bucket-2012-08-20-1704")
    #get a new deltacloud handle using eu-west-1
    @dcloud_other_provider = Deltacloud::new(:ec2, credentials.merge!(:provider=>"eu-west-1"))
    #get the bucket and check
    retrieved_bucket = @dcloud_other_provider.bucket(:id=>bucket.name)
    retrieved_bucket.must_be_kind_of Deltacloud::Bucket
    retrieved_bucket.name.must_equal bucket.name
    #delete the bucket
    @driver.delete_bucket(bucket.id)
  end

end

