require 'vcr'

require_relative '../../test_helper'

def credentials
  {
    :user => 'GOOG4PBMMHEB2BTY6Q7U',
    :password => '7NxqwXy85xmaWB6o1RZ66IxqP+Rmbu8UFiFdpcSw'
  }
end

def created_blob_local_file
  File.join(File.dirname(__FILE__),"data","deltacloud_blob_test.png")
end

VCR.configure do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/fixtures/"
  c.hook_into :excon
  c.default_cassette_options = { :record => :new_episodes }
end
