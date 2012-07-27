require 'minitest/autorun'
require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::Keys do

  before do
    def app; Deltacloud::API; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:keys)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::KeysCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::KeysCollection::ShowOperation
  end

  it 'returns list of keys in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/keys'
      status.must_equal 200
    end
  end

  it 'returns details about key in various formats with show operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/keys/test-key'
      status.must_equal 200
    end
  end

  it 'provides URL to create new key' do
    header 'Accept', 'text/html'
    get root_url + '/keys/new'
    status.must_equal 200
    response_body.must_include 'Create new SSH key'
  end

  it 'must support creating and destroying keys' do
    post root_url + '/keys', { :name => 'unit-test1' }
    status.must_equal 201
    xml.root.name.must_equal 'key'
    xml.root[:id].must_equal 'unit-test1'
    (xml/'key/pem').wont_be_empty
    Proc.new {
      post root_url + '/keys', { :name => 'unit-test1' }
    }.must_raise Deltacloud::ExceptionHandler::ProviderError, 'keyExist'
    delete root_url + '/keys/unit-test1'
    status.must_equal 204
  end

  it 'reports 404 when querying non-existing key' do
    get root_url + '/keys/unknown'
    status.must_equal 404
  end

end
