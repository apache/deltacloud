require 'yaml'

API_HOST = 'localhost'
API_PORT = 3000
API_PATH = '/api'

API_URL = "http://#{API_HOST}:#{API_PORT}#{API_PATH}"

credentials = YAML.load( File.read( File.dirname( __FILE__ ) + '/../credentials.yml' ) )

API_NAME     = credentials['name']
API_PASSWORD = credentials['password']

$: << File.dirname( __FILE__ ) + '/../lib'
require 'deltacloud'
