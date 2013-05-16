require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::Systems do

  before do
    def app; run_frontend(:cimi) end
    authorize 'mockuser', 'mockpassword'
    @collection = CIMI::Collections.collection(:systems)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal CIMI::Rabbit::SystemsCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal CIMI::Rabbit::SystemsCollection::ShowOperation
  end

  it 'returns list of systems in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/systems'
      status.must_equal 200
    end
  end

  it 'should allow to retrieve the single system' do
    get root_url '/systems/system1'
    status.must_equal 200
    xml.root.name.must_equal 'System'
  end

  it 'should have legal status' do
    get root_url '/systems'
    status.must_equal 200
    (xml/'Collection/System').each do |s|
      (s/'state').wont_be_empty
      (s/'state').inner_text.must_equal 'STOPPED'
    end
  end

  it 'should not return non-existing system' do
    get root_url '/systems/unknown-system'
    status.must_equal 404
  end

  it 'returns list of system machines in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url '/systems/system1/machines'
      status.must_equal 200
    end
  end

  it 'returns list of system machines with ids' do
    get root_url '/systems/system1/machines'
    xml.root.name.must_equal 'Collection'
    (xml/'Collection/count').inner_text.must_equal '1'
    (xml/'Collection/SystemMachine').each do |s|
      (s/'id').wont_be_empty
    end
  end

  it 'returns list of system volumes in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url '/systems/system1/volumes'
      status.must_equal 200
    end
  end

  it 'returns list of system volumes with ids' do
    get root_url '/systems/system1/volumes'
    xml.root.name.must_equal 'Collection'
    (xml/'Collection/count').inner_text.must_equal '1'
    (xml/'Collection/SystemVolume').each do |s|
      (s/'id').wont_be_empty
    end
  end

end
