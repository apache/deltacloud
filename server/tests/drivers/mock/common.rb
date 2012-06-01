ENV['API_DRIVER']   = 'mock'
ENV['TESTS_API_USERNAME'] = 'mockuser'
ENV['TESTS_API_PASSWORD'] = 'mockpassword'


$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/minitest_common'
