require 'minitest/autorun'
require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::Instances do

  before do
    def app; Deltacloud::API; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:instances)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::InstancesCollection::IndexOperation
  end

  it 'provides URL to specify new instance' do
    header 'Accept', 'text/html'
    get root_url + '/instances/new?image_id=img1'
    status.must_equal 200
  end


end
