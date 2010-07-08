
API_HOST = 'localhost'
API_PORT = 3000
API_PATH = '/api'

API_URL = "http://#{API_HOST}:#{API_PORT}#{API_PATH}"

$: << File.dirname( __FILE__ ) + '/../lib'
require 'deltacloud'
