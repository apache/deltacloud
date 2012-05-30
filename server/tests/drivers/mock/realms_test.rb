$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API Realms' do
  include Deltacloud::Test

  it 'must advertise have the realms collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link[@rel=realms]').wont_be_empty
  end

  it 'must require authentication to access the "realm" collection' do
    get collection_url(:realms)
    last_response.status.must_equal 401
  end

  it 'should respond with HTTP_OK when accessing the :realms collection with authentication' do
    authenticate
    get collection_url(:realms)
    last_response.status.must_equal 200
  end

  it 'should support the JSON media type' do
    authenticate
    header 'Accept', 'application/json'
    get collection_url(:realms)
    last_response.status.must_equal 200
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must include the ETag in HTTP headers' do
    authenticate
    get collection_url(:realms)
    last_response.headers['ETag'].wont_be_nil
  end

  it 'must have the "realms" element on top level' do
    authenticate
    get collection_url(:realms)
    xml_response.root.name.must_equal 'realms'
  end

  it 'must have some "realm" elements inside "realms"' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').wont_be_empty
  end

  it 'must provide the :id attribute for each realm in collection' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "realm" element in collection' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the realm' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must return the list of valid parameters for the :index action' do
    authenticate
    options collection_url(:realms) + '/index'
    last_response.headers['Allow'].wont_be_nil
  end

  it 'must have the "name" element defined for each realm in collection' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      (r/'name').wont_be_empty
    end
  end

  it 'must have the "state" element defined for each realm in collection' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      (r/'state').wont_be_empty
    end
  end

  it 'must return the full "realm" when following the URL in realm element' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      get collection_url(:realms) + '/' + r[:id]
      last_response.status.must_equal 200
    end
  end

  it 'must have the "name" element for the realm and it should match with the one in collection' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      get collection_url(:realms) + '/' + r[:id]
      (xml_response/'name').wont_be_empty
      (xml_response/'name').first.text.must_equal((r/'name').first.text)
    end
  end

  it 'must have the "state" element for the realm and it should match with the one in collection' do
    authenticate
    get collection_url(:realms)
    (xml_response/'realms/realm').each do |r|
      get collection_url(:realms) + '/' + r[:id]
      (xml_response/'state').wont_be_empty
      (xml_response/'state').first.text.must_equal((r/'state').first.text)
    end
  end

end
