require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require_relative './common'
require_relative '../../../lib/deltacloud/drivers/exceptions'

class TestException < StandardError; end

class ExceptionTestClass
  include Deltacloud::ExceptionHandler

  def raise_exception(id)
    case id
      when 1 then safely { raise 'test1 exception' }
      when 2 then safely { raise TestException }
      when 3 then safely { raise 'not captured' }
    end
  end

  exceptions do
    on /test1/ do
      status 500
      message 'Test1ErrorMessage'
    end
    on TestException do
      status 400
      message 'StandardErrorTest'
    end
  end
end

def raise_error(id); ExceptionTestClass.new.raise_exception(id); end

describe Deltacloud::ExceptionHandler do

  it 'should capture exception when match the exception message' do
    lambda { raise_error 1 }.must_raise Deltacloud::ExceptionHandler::BackendError

    begin raise_error(1); rescue Deltacloud::ExceptionHandler::BackendError => e
      e.code.must_equal 500
      e.message.must_equal 'Test1ErrorMessage'
      e.backtrace.wont_be_empty
    end

  end

  it 'should capture exception when match the exception class' do
    lambda { raise_error 2 }.must_raise Deltacloud::ExceptionHandler::ValidationFailure
    begin raise_error(2); rescue Deltacloud::ExceptionHandler::ValidationFailure => e
      e.code.must_equal 400
      e.message.must_equal 'StandardErrorTest'
      e.backtrace.wont_be_empty
    end
  end

  it 'should capture exception when no match found' do
    lambda { raise_error 3 }.must_raise Deltacloud::ExceptionHandler::BackendError
    begin raise_error(3); rescue Deltacloud::ExceptionHandler::BackendError => e
      e.code.must_equal 500
      e.message.must_equal 'Unhandled exception or status code (not captured)'
      e.backtrace.wont_be_empty
    end
  end

end
