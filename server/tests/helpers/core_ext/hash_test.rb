require 'minitest/autorun'

load File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'deltacloud', 'core_ext.rb')

class TestHash < MiniTest::Unit::TestCase


  def test_gsub_keys
    assert_equal true, {}.respond_to?(:"gsub_keys")
    h = {
      :'test-key-1' => '1',
      :'test-key-2' => '2',
      'test-key-3' => '3',
      :random => '10'
    }

    h.gsub_keys(/test/, 'new')

    assert_equal '1', h['new-key-1']
    assert_equal '2', h['new-key-2']
    assert_equal '3', h['new-key-3']
    assert_equal '10', h[:random]
  end

  def test_symbolize_keys
    assert_equal true, {}.respond_to?(:"symbolize_keys")
    h = {
      'test1' => 1,
      :test3 => 3
    }

    h.symbolize_keys

    assert_equal 1, h[:test1]
    assert_equal nil, h['test1']
    assert_equal 3, h[:test3]

  end

end
