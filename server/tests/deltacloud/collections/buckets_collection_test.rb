require 'rubygems'
require 'require_relative'

require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::Buckets do

  before do
    def app; Deltacloud::API; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:buckets)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::BucketsCollection::IndexOperation
  end

  it 'provides URL to specify new bucket' do
    header 'Accept', 'text/html'
    get root_url + '/buckets/new/' + Deltacloud::Helpers::Application::NEW_BLOB_FORM_ID
    status.must_equal 200
  end

  it 'returns list of buckets in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/buckets'
      status.must_equal 200
    end
  end

  it 'must support creating a new bucket and destroying it' do
    post root_url + '/buckets', { :name => 'test-bucket1' }
    status.must_equal 201
    xml.root.name.must_equal 'bucket'
    delete root_url + '/buckets/' + xml.root[:id]
    status.must_equal 204
  end

  it 'returns blob metadata' do
    head root_url + '/buckets/bucket1/blob1'
    headers['X-Deltacloud-Blobmeta-SOMENEWKEY'].must_equal 'NEWVALUE'
    status.must_equal 204
    head root_url + '/buckets/bucket1/non-existing-blob'
    status.must_equal 404
  end

  it 'returns blob details on show operation in various formats' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/buckets/bucket1/blob1'
      last_response
      status.must_equal 200
    end
  end

  it 'creates a new blob and then destroy it' do
    post root_url + '/buckets/bucket1', { :blob_id => 'test-blob', :blob_data => 'test', :meta_params => '1', :meta_name1 => 'test-meta1' }
    status.must_equal 201
    delete root_url + '/buckets/bucket1/test-blob'
    status.must_equal 204
  end


end
