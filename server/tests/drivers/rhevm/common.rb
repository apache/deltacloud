require 'vcr'

require_relative '../../test_helper'

# Credentials used to access RHEV-M server
#
# NOTE: If these are changed, the VCR fixtures need to be re-recorded
#
def credentials
  {
    :user => 'admin@internal',
    :password => 'redhat',
    :provider => 'https://dell-per610-02.lab.eng.brq.redhat.com/api;9df72b84-0234-11e2-9b87-9386d9b09d4a'
  }
end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Set :record to :all, when re-recording and between re-record attemps
  # be sure to clear fixtures/*.yml files which can be done with "git checkout".
  # e.g.:
  # c.default_cassette_options = { :record => :all }
  c.default_cassette_options = { :record => :none }
end
