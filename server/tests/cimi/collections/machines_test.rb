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
    @collection.operation(:index).must_equal Sinatra::Rabbit::MachinesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::MachinesCollection::ShowOperation
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

  it 'should not return non-existing machine' do
    get root_url '/machines/unknown-machine'
    status.must_equal 404
  end

end
