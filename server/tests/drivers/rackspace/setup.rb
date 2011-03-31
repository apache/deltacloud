ENV['API_DRIVER']   = "rackspace"
ENV['API_USER']     = 'michalfojtik'
ENV['API_PASSWORD'] = '1f82168de18f91542834f1e861f37420'

require 'vcr'
VCR.config do |c|
  c.cassette_library_dir = 'tests/rackspace/fixtures/'
  c.stub_with :webmock
  c.default_cassette_options = { :record => :new_episodes }
end
