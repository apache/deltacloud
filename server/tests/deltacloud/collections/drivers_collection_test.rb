require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::Drivers do

  before do
    def app; run_frontend; end
    @collection = Deltacloud::Collections.collection(:drivers)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::DriversCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::DriversCollection::ShowOperation
  end

  it 'returns list of drivers in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/drivers'
      status.must_equal 200
    end
  end

  it 'returns details about driver in various formats with show operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/drivers/mock'
      status.must_equal 200
    end
  end

end
