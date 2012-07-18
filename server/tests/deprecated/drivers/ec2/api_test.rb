$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/ec2/common'

describe 'Deltacloud API' do

  before do
    Timecop.freeze(FREEZED_TIME)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  include Deltacloud::Test

  eval File.read('tests/minitest_common_api_test.rb')

end
