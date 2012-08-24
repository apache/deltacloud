require 'vcr'

require_relative '../../test_helper.rb'

def credentials
  {
    :user => '9bbf139b8b57d967',
    :password => 'gogridtest'
  }
end

unless Time.respond_to? :be
  require 'time'

  # This code was originally copied from:
  # https://github.com/jtrupiano/timecop/issues/8#issuecomment-1396047
  #
  # Since 'timecop' gem has broken 'timezone' support, this small monkey-patching
  # on Time object seems to fix this issue.

  unless Time.respond_to? :be
    class Time
      module TimeMock
        attr_accessor :mock_time

        def mock_now
          @mock_time || Time.original_now
        end

        def be(a_time)
          @mock_time = Time.parse(a_time)
        end

      end

      class << self
        include TimeMock
        alias_method :original_now, :now
        alias_method :now, :mock_now
      end
    end
  end
end

VCR.configure do |c|
  # NOTE: Empty this directory before re-recording
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures')
  c.hook_into :webmock
  # Set this to :new_episodes when you want to 're-record'
  c.default_cassette_options = { :record => :new_episodes }
end
