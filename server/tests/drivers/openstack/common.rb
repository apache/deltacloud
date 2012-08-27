require 'openstack'
require 'vcr'

def credentials
  {
    :user => 'admin+admin',
    :password => 'password',
    :provider => 'http://10.34.32.211:5000/v2.0'
  }
end

def openstack_image_id
  'bf7ce59a-d9f9-45d4-9313-f45b16436602'
end

unless Time.respond_to? :be
  require_relative '../../test_helper.rb'
end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Set this to :new_episodes when you want to 're-record'
  c.default_cassette_options = { :record => :new_episodes }
end
