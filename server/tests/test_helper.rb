require 'pp'

ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
  begin
    require 'simplecov'
  rescue LoadError
    warn "To generate code coverage you need to install 'simplecov' (gem install simplecov OR bundle)"
  end
end

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require 'time'

# This code was originally copied from:
# https://github.com/jtrupiano/timecop/issues/8#issuecomment-1396047
#
# Since 'timecop' gem has broken 'timezone' support, this small monkey-patching
# on Time object seems to fix this issue.

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

def record_retries(name='')
  {
    :before => Proc.new { |r, &block|
      VCR.use_cassette("#{__name__}-#{name.empty? ? '' : "#{name}-"}#{r}", &block)
    }
  }
end
