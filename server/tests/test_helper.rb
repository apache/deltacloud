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
