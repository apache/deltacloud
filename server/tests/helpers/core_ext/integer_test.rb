require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative '../../test_helper.rb'
require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'core_ext.rb')

class TestInteger < MiniTest::Unit::TestCase


  def test_ordinalize
    assert_equal true, 1.respond_to?(:"ordinalize")
    assert_equal '1st', 1.ordinalize
    assert_equal '2nd', 2.ordinalize
    assert_equal '3rd', 3.ordinalize
    assert_equal '6th', 6.ordinalize
    assert_equal '1211th', 1211.ordinalize
  end

end
