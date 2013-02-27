require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::Realms do

  before do
    def app; run_frontend; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:realms)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Deltacloud::Rabbit::RealmsCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Deltacloud::Rabbit::RealmsCollection::ShowOperation
  end

  it 'returns list of realms in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/realms'
      status.must_equal 200
    end
  end

  it 'returns details about key in various formats with show operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/realms/eu'
      status.must_equal 200
    end
  end

  it 'reports 404 when querying non-existing key' do
    get root_url + '/realms/unknown'
    status.must_equal 404
  end

  it 'properly serialize attributes in JSON' do
    check_json_serialization_for :realm, 'us'
  end

end
