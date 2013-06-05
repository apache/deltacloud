require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'
require 'minitest/autorun'
require_relative './common.rb'

describe CIMI::Collections::Machines do

  NS = { "c" => "http://schemas.dmtf.org/cimi/1" }

  before do
    def app; run_frontend(:cimi) end
    authorize 'mockuser', 'mockpassword'
    @collection = CIMI::Collections.collection(:machines)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal CIMI::Rabbit::MachinesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal CIMI::Rabbit::MachinesCollection::ShowOperation
  end

  it 'returns list of machines in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/machines'
      status.must_equal 200
    end
  end

  it 'should allow to retrieve the single machine' do
    get root_url '/machines/inst1'
    status.must_equal 200
    xml.root.name.must_equal 'Machine'
  end

  it 'should have an "add" operation for the machine collection' do
    skip # FIXME: The MachineCollection is not initialized at this point. This must have something with
         # the way how we load models.... Let's investigate in future.

    get root_url + '/machines'
    model.operations.wont_be_empty
    add_ops = model.operations.select { |op| op.rel == "add" }
    add_ops.size.must_equal 1
  end

  it "should return the disks collection for a machine" do
    skip # FIXME: The MachineCollection is not initialized at this point. This must have something with
         # the way how we load models.... Let's investigate in future.
    get root_url + '/machines'
    model.operations.wont_be_empty
    href = model.entries.first.disks[:href]
    href.wont_be_empty
    get href
    status.must_equal 200
    model.must_be_kind_of CIMI::Model::Machine::DiskCollection
    model.entries.size.must_equal 1
    #model.entries.first.name.must_equal "inst0_disk_0"
  end

  describe "$expand" do
    def machine(*expand)
      url = '/machines/inst1'
      url += "?$expand=#{expand.join(",")}" unless expand.empty?
      get root_url url
      status.must_equal 200
    end

    def ids(coll)
      xml.xpath("/c:Machine/c:#{coll}/c:id", NS)
    end

    it "should not expand collections when missing" do
      machine
      ids(:disks).must_be_empty
      ids(:volumes).must_be_empty
    end

    it "should expand named collections" do
      machine :disks
      ids(:disks).size.must_equal 1
      ids(:volumes).must_be_empty
    end

    it "should expand multiple named collections" do
      machine :disks, :volumes
      ids(:disks).size.must_equal 1
      ids(:volumes).size.must_equal 1
    end

    it "should expand all collections with *" do
      machine "*"
      ids(:disks).size.must_equal 1
      ids(:volumes).size.must_equal 1
    end
  end

  describe '$filter' do

    it 'should filter collection by name attribute' do
      get root_url("/machines?$filter=name='MockUserInstance'")
      status.must_equal 200
      (xml/'Collection/Machine').wont_be_empty
      (xml/'Collection/Machine').size.must_equal 1
      xml.at('Collection/count').text.must_equal '1'
      xml.at('Collection/Machine/name').text.must_equal 'MockUserInstance'
    end

    it 'should filter collection by reverse name attribute' do
      get root_url("/machines?$filter=name!='MockUserInstance'")
      status.must_equal 200
      (xml/'Collection/Machine').wont_be_empty
      (xml/'Collection/Machine').size.must_equal 3
      xml.at('Collection/count').text.must_equal '3'
      xml.at('Collection/Machine/name').text.must_equal 'Mock Instance With Profile Change'
    end

  end

  describe '$select' do

    it 'should return only selected attribute' do
      get root_url('/machines?$select=name')
      status.must_equal 200
      (xml/'Collection/Machine/name').wont_be_empty
      (xml/'Collection/Machine/name').first.text.wont_be_empty
      xml.xpath("/c:Collection/c:Machine/*[not(self::c:name)]", NS).must_be_empty
    end

    it 'should support multiple selected attributes' do
      get root_url('/machines?$select=name,description')
      status.must_equal 200
      (xml/'Collection/Machine/name').wont_be_empty
      (xml/'Collection/Machine/name').first.text.wont_be_empty
      (xml/'Collection/Machine/description').wont_be_empty
      (xml/'Collection/Machine/description').first.text.wont_be_empty
      xml.xpath("/c:Collection/c:Machine/*[not(self::c:name) and not(self::c:description)]", NS).must_be_empty
    end

    it 'should support select on non-expanded subcollection' do
      get root_url('/machines?$select=disks')
      xml.xpath("/c:Collection/c:Machine/*[not(self::c:disks)]", NS).must_be_empty
      (xml/'Collection/Machine/disks').wont_be_empty
      (xml/'Collection/Machine/disks').each do |d|
        d[:href].wont_be_empty
        d[:href].must_match(/^http/)
        d.children.must_be_empty
      end
    end

    def disks
      (xml/'Collection/Machine/disks').wont_be_empty
      (xml/'Collection/Machine/disks').each do |d|
        d[:href].wont_be_empty
        d[:href].must_match(/^http/)
        d.at('id').wont_be_nil
        d.at('count').wont_be_nil
        d.at('Disk/id').wont_be_nil
        d.at('Disk/description').wont_be_nil
        d.at('Disk/capacity').wont_be_nil
        d.at('Disk/created').wont_be_nil
      end
    end

    it 'should support select on expanded subcollection' do
      get root_url('/machines?$select=disks&$expand=disks')
      xml.xpath("/c:Collection/c:Machine/*[not(self::c:disks)]", NS).must_be_empty
      disks
    end

    it 'should support select on expanded subcollection and regular attribute' do
      get root_url('/machines?$select=name,disks&$expand=disks')
      xml.xpath("/c:Collection/c:Machine/*[not(self::c:disks) and not(self::c:name)]", NS).must_be_empty
      disks
    end
  end

  it 'should not return non-existing machine' do
    get root_url '/machines/unknown-machine'
    status.must_equal 404
  end

end
