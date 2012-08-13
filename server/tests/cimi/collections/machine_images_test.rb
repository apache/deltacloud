require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::MachineImages do

  before do
    def app; CIMI::API; end
    authorize 'mockuser', 'mockpassword'
    @collection = CIMI::Collections.collection(:machine_images)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::MachineImagesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::MachineImagesCollection::ShowOperation
  end

  it 'returns list of images in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/machine_images'
      status.must_equal 200
    end
  end

  it 'should allow to retrieve the single image' do
    get root_url '/machine_images/img1'
    status.must_equal 200
    xml.root.name.must_equal 'MachineImage'
  end

  it 'should allow to filter using CIMISelect' do
    get root_url '/machine_images?CIMISelect=description'
    status.must_equal 200
    xml.root.name.must_equal 'MachineImageCollection'
    (xml/'description').wont_be_empty
    (xml/'id').must_be_empty
  end

end
