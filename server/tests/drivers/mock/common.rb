ENV['API_DRIVER']   = 'mock'
ENV['API_USERNAME'] = 'mockuser'
ENV['API_PASSWORD'] = 'mockpassword'


$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/minitest_common'
