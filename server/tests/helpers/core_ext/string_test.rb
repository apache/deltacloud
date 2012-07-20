require 'minitest/autorun'

require_relative File.join('..', '..', '..', 'lib', 'deltacloud', 'core_ext.rb')

class TestString < MiniTest::Unit::TestCase


  def test_blank?
    assert_equal true, ''.respond_to?(:"blank?")
    assert_equal true, ''.blank?
    assert_equal true, ' '.blank?
    assert_equal false, 'test'.blank?
  end

  def test_titlecase
    assert_equal true, ''.respond_to?(:"titlecase")
    assert_equal "This Is A String", 'this is a string'.titlecase
    assert_equal 'This', 'this'.titlecase
  end

  def test_pluralize
    assert_equal true, ''.respond_to?(:"pluralize")
    assert_equal 'instances', 'instance'.pluralize
    assert_equal 'properties', 'property'.pluralize
    assert_equal 'addresses', 'address'.pluralize
  end

  def test_singularize
    assert_equal true, ''.respond_to?(:"singularize")
    assert_equal 'instance', 'instances'.singularize
    assert_equal 'property', 'properties'.singularize
    assert_equal 'address', 'addresses'.singularize
  end

  def test_underscore
    assert_equal true, ''.respond_to?(:"underscore")
    assert_equal 'test_model', 'TestModel'.underscore
    assert_equal 'test/model', 'Test::Model'.underscore
  end

  def test_camelize
    assert_equal true, ''.respond_to?(:"camelize")
    assert_equal 'TestModel', 'test_model'.camelize
    assert_equal 'testModel', 'test_model'.camelize(:lowercase_first_letter)
  end

  def test_uncapitalize
    assert_equal true, ''.respond_to?(:"uncapitalize")
    assert_equal 'testModel', 'TestModel'.uncapitalize
    assert_equal 'test', 'Test'.uncapitalize
  end

  def test_upcase_first
    assert_equal true, ''.respond_to?(:"upcase_first")
    assert_equal 'Test', 'test'.upcase_first
    assert_equal 'Test', 'Test'.upcase_first
    assert_equal 'TestModel', 'testModel'.upcase_first
  end

  def test_truncate
    assert_equal true, ''.respond_to?(:"truncate")
    assert_equal 'ThisIs...cated', 'ThisIsALogStringThatNeedsToBeTruncated'.truncate
    assert_equal 'Thi...ed', 'ThisIsALogStringThatNeedsToBeTruncated'.truncate(5)
    assert_equal 'T...', 'ThisIsALogStringThatNeedsToBeTruncated'.truncate(1)
    assert_equal 'This', 'This'.truncate(10)
  end

  def test_it_has_each
    assert_equal true, ''.respond_to?(:each)
  end

end
