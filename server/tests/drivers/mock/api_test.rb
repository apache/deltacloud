$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API' do

  include Deltacloud::Test

  eval File.read('tests/minitest_common_api_test.rb')

end
