require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe Deltacloud do

  it 'must provide list of available collections names' do
    Deltacloud.collection_names.wont_be_empty
    Deltacloud.collection_names.must_include :drivers
  end

  it 'must provide access to collection classes' do
    Deltacloud.collections.wont_be_empty
    Deltacloud.collections.must_include Sinatra::Rabbit::DriversCollection
  end

  describe Deltacloud::Collections do

    it 'must return collection by name' do
      Deltacloud::Collections.must_respond_to :collection
      Deltacloud::Collections.collection(:drivers).wont_be_nil
      Deltacloud::Collections.collection(:drivers).must_equal Sinatra::Rabbit::DriversCollection
    end

    it 'must provide access to Deltacloud Sinatra modules' do
      Deltacloud::Collections.must_respond_to :deltacloud_modules
      Deltacloud::Collections.deltacloud_modules.wont_be_empty
      Deltacloud::Collections.deltacloud_modules.must_include Deltacloud::Collections::Drivers
    end

  end


end
