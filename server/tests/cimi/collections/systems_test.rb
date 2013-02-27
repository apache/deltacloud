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

end
