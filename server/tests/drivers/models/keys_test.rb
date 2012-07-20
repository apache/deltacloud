require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'base_model.rb')
require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'models', 'key.rb')

describe Key do

  before do
    @key = Key.new(:credential_type => :key)
  end

  it 'advertise if it is password or key' do
    @key.is_password?.must_equal false
    @key.is_key?.must_equal true
  end

  it 'cat generate the mock fingerprint' do
    Key.generate_mock_fingerprint.must_match /(\w{2}:?)/
  end

  it 'can generate the mock PEM key' do
    Key.generate_mock_pem.must_include 'PRIVATE KEY'
  end

end
