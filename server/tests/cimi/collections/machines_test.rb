require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::Machines do

  before do
    def app; CIMI::API; end
    authorize 'mockuser', 'mockpassword'
    @collection = CIMI::Collections.collection(:machines)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::MachinesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::MachinesCollection::ShowOperation
  end

  it 'returns list of machines in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/machines'
      status.must_equal 200
    end
  end

  it 'should allow to retrieve the single machine' do
    get root_url '/machines/inst1'
    status.must_equal 200
    xml.root.name.must_equal 'Machine'
  end

  it 'should not return non-existing machine' do
    get root_url '/machines/unknown-machine'
    status.must_equal 404
  end

end
