require 'vcr'

def credentials
  {
    :user => '9bbf139b8b57d967',
    :password => 'gogridtest'
  }
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

