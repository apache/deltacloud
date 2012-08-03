require 'rubygems'
require 'require_relative'
require_relative '../../test_helper.rb'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'core_ext.rb')

class TestArray < MiniTest::Unit::TestCase


  def test_expand_opts!
    assert_equal true, [].respond_to?(:"expand_opts!")
    a = [1,2,3]
    a.expand_opts!(:test => 1)
    assert_equal Hash, a.last.class
  end

  def test_extract_opts!
    assert_equal true, [].respond_to?(:"extract_opts!")
    a = [1,2,3, { :test => 1}]
    a.extract_opts!
    assert_equal [1,2,3], a
  end

end
