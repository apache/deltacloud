require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common'

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
