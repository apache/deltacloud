require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::SystemTemplates do

  before do
    def app; run_frontend(:cimi) end
    authorize 'mockuser', 'mockpassword'
    @collection = CIMI::Collections.collection(:system_templates)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::SystemTemplatesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::SystemTemplatesCollection::ShowOperation
  end

  it 'returns list of system templates in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/system_templates'
      status.must_equal 200
    end
  end

  it 'should allow to retrieve the single system template' do
    get root_url '/system_templates/template1'
    status.must_equal 200
    xml.root.name.must_equal 'SystemTemplate'
  end

  it 'should not return non-existing system_template' do
    get root_url '/system_templates/unknown-system_template'
    status.must_equal 404
  end

end
