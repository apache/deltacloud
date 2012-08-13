require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::InstanceStates do

  before do
    def app; Deltacloud::API; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:instance_states)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::InstanceStatesCollection::IndexOperation
  end

  it 'returns list of states for current driver in various formats with index operation' do
    get root_url + '/instance_states'
    status.must_equal 200
    xml.root.name.must_equal 'states'
    header 'Accept', 'application/json'
    get root_url + '/instance_states'
    status.must_equal 200
    JSON::parse(response_body).must_be_kind_of Array
    JSON::parse(response_body).wont_be_empty
    header 'Accept', 'image/png'
    get root_url + '/instance_states'
    status.must_equal 200
    last_response.content_type.must_equal 'image/png'
  end


end
