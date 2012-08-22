require 'vcr'

def credentials
  {
    :user => 'GOOGXKQLYTEOZTILUBZ5',
    :password => 'M3pvZUy2ivT78ipQ+u1xv6TkY83q9DUnGXkov3tA'
  }
end

def created_blob_local_file
  File.join(File.dirname(__FILE__),"data","deltacloud_blob_test.png")
end

VCR.configure do |c|
  c.cassette_library_dir = "#{File.dirname(__FILE__)}/fixtures/"
  c.hook_into :excon
  c.default_cassette_options = { :record => :none }
end
