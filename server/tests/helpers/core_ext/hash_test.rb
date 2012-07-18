require 'minitest/autorun'

load File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'deltacloud', 'core_ext.rb')

class TestHash < MiniTest::Unit::TestCase


  def test_gsub_keys
    assert_equal true, {}.respond_to?(:"gsub_keys")
    h = {
      :'test-key-1' => '1',
      :'test-key-2' => '2',
      :'test-key-3' => '3',
    }
    h.gsub_keys(/test-key/, 'test')
    assert_equal h['test-1'], '1'
    assert_equal h['test-2'], '2'
    assert_equal h['test-3'], '3'
  end

end
