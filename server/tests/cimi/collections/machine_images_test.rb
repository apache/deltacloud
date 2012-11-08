require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::MachineImages do

  before do
    def app; run_frontend(:cimi) end
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

  describe "filtering with $select" do
    def machines(*select)
      url = "/machine_images"
      url += "?$select=#{select.join(",")}" unless select.empty?
      get root_url url
      status.must_equal 200
    end

    it 'should filter collection members' do
      machines :description
      (xml/'id').wont_be_empty
      nimages = (xml/'MachineImage').size
      (xml/'MachineImage/description').size.must_equal nimages
      (xml/'MachineImage/id').must_be_empty
    end

    it 'should filter by multiple attributes' do
      machines :description, :id
      (xml/'id').wont_be_empty
      nimages = (xml/'MachineImage').size
      (xml/'MachineImage/description').size.must_equal nimages
      (xml/'MachineImage/id').size.must_equal nimages
    end
  end

end
