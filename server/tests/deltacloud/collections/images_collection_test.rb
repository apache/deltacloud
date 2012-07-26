require 'minitest/autorun'
require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::Images do

  before do
    def app; Deltacloud::API; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:images)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::ImagesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::ImagesCollection::ShowOperation
  end

  it 'returns list of images in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/images'
      status.must_equal 200
    end
  end

  it 'returns details about image in various formats with show operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/images/img1'
      status.must_equal 200
    end
  end

  it 'provides URL to specify new image' do
    header 'Accept', 'text/html'
    get root_url + '/images/new?instance_id=inst1'
    status.must_equal 200
    get root_url + '/images/new'
    status.must_equal 404
  end

  it 'allow to create and destroy the new image' do
    post root_url + '/images', { :instance_id => 'inst1', :name => 'img-test1', :description => 'test image' }
    status.must_equal 201
    xml.root[:id].wont_be_nil
    delete root_url + '/images/' + xml.root[:id]
    status.must_equal 204
  end

  it 'reports 404 when querying non-existing image' do
    get root_url + '/images/non-existing-one'
    status.must_equal 404
  end

end
