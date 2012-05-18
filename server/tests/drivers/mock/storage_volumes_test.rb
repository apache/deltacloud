$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API storage_volumes' do
  include Deltacloud::Test

  it 'must advertise have the storage_volumes collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link[@rel=storage_volumes]').wont_be_empty
  end

  it 'must require authentication to access the "storage_volume" collection' do
    get collection_url(:storage_volumes)
    last_response.status.must_equal 401
  end

  it 'should respond with HTTP_OK when accessing the :storage_volumes collection with authentication' do
    auth_as_mock
    get collection_url(:storage_volumes)
    last_response.status.must_equal 200
  end

  it 'should support the JSON media type' do
    auth_as_mock
    header 'Accept', 'application/json'
    get collection_url(:storage_volumes)
    last_response.status.must_equal 200
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must include the ETag in HTTP headers' do
    auth_as_mock
    get collection_url(:storage_volumes)
    last_response.headers['ETag'].wont_be_nil
  end

  it 'must have the "storage_volumes" element on top level' do
    auth_as_mock
    get collection_url(:storage_volumes)
    xml_response.root.name.must_equal 'storage_volumes'
  end

  it 'must have some "storage_volume" elements inside "storage_volumes"' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').wont_be_empty
  end

  it 'must provide the :id attribute for each storage_volume in collection' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "storage_volume" element in collection' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the storage_volume' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must return the list of valid parameters for the :index action' do
    auth_as_mock
    options collection_url(:storage_volumes) + '/index'
    last_response.headers['Allow'].wont_be_nil
  end

  it 'must have the "name" element defined for each storage_volume in collection' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      (r/'name').wont_be_empty
    end
  end

  it 'must have the "state" element defined for each storage_volume in collection' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      (r/'state').wont_be_empty
    end
  end

  it 'must return the full "storage_volume" when following the URL in storage_volume element' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      get collection_url(:storage_volumes) + '/' + r[:id]
      last_response.status.must_equal 200
    end
  end

  it 'must have the "name" element for the storage_volume and it should match with the one in collection' do
    auth_as_mock
    get collection_url(:storage_volumes)
    (xml_response/'storage_volumes/storage_volume').each do |r|
      get collection_url(:storage_volumes) + '/' + r[:id]
      (xml_response/'name').wont_be_empty
      (xml_response/'name').first.text.must_equal((r/'name').first.text)
    end
  end

end
