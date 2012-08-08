require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/
require 'minitest/autorun'

require_relative '../lib/deltacloud.rb'

# Configuration:

API_HOST = 'localhost'
API_PORT = '3001'
API_PATH = '/api'

API_NAME = 'mockuser'
API_PASSWORD = 'mockpassword'

API_URL_REDIRECT = "http://#{API_HOST}:#{API_PORT}"
API_URL = "#{API_URL_REDIRECT}#{API_PATH}"
