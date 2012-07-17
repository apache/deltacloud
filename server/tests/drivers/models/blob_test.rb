require 'minitest/autorun'

load File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'deltacloud', 'models', 'base_model.rb')
load File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'deltacloud', 'models', 'address.rb')

describe Address do

  before do
    @address = Address.new(:id => 'adr1', :instance_id => 'inst1')
  end

  it 'should tell if it is associated to instance' do
    @address.associated?.must_equal true
    @address.instance_id = nil
    @address.associated?.must_equal false
  end

end
