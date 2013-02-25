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
    @collection.operation(:index).must_equal CIMI::Rabbit::SystemTemplatesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal CIMI::Rabbit::SystemTemplatesCollection::ShowOperation
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

  it 'should allow to retrieve system template\'s machine template\'s ref details' do
    get root_url '/system_templates/template1'
    (xml/'SystemTemplate/componentDescriptor').each do |c|
      if (c/'name').inner_text == 'my third machine'
        (c/'machineTemplate').wont_be_empty
        (c/'machineTemplate').to_s.must_equal '<machineTemplate href="http://example.com/machine_templates/template1"/>'
      end
    end
  end

  it 'should allow to retrieve system template\'s machine template\'s inline details' do
    get root_url '/system_templates/template1'
    (xml/'SystemTemplate/componentDescriptor').each do |c|
      if (c/'name').inner_text == 'my machine'
        (c/'machineTemplate').wont_be_empty
        (c/'machineTemplate/name').inner_text.must_equal 'machine in mock system'
        (c/'machineTemplate/description').inner_text.must_equal 'machine in system'
        (c/'machineTemplate/machineConfig').to_s.must_equal '<machineConfig href="http://example.com/configs/m1-small"/>'
        (c/'machineTemplate/machineImage').to_s.must_equal '<machineImage href="http://example.com/images/img1"/>'
        (c/'machineTemplate/volumeTemplate').to_s.must_equal '<volumeTemplate href="http://example.com/volumes/sysvol1"/>'
      end
    end
  end

  it 'should allow to retrieve system template\'s machine template\'s inline volume template' do
    get root_url '/system_templates/template1'
    (xml/'SystemTemplate/componentDescriptor').each do |c|
      if (c/'name').inner_text == 'my second machine'
        (c/'machineTemplate').wont_be_empty
        (c/'machineTemplate/description').inner_text.must_equal 'another inline mock machine template'
        (c/'machineTemplate/volumeTemplate').wont_be_empty
        (c/'machineTemplate/volumeTemplate/volumeConfig').wont_be_empty
        (c/'machineTemplate/volumeTemplate/volumeConfig/capacity').inner_text.must_equal '10485760'
      end
    end
  end

  it 'should allow to retrieve system template\'s network' do
    get root_url '/system_templates/template1'
    (xml/'SystemTemplate/componentDescriptor').each do |c|
      if (c/'name').inner_text == 'network in mock system'
        (c/'networkTemplate').inner_text.must_equal 'my network'
        (c/'networkTemplate/networkConfig/networkType').inner_text.must_equal 'GOLD'
      end
    end
  end

end
