$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API buckets' do
  include Deltacloud::Test

  it 'must advertise have the buckets collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link[@rel=buckets]').wont_be_empty
  end

  it 'must require authentication to access the "bucket" collection' do
    get collection_url(:buckets)
    last_response.status.must_equal 401
  end

  it 'should respond with HTTP_OK when accessing the :buckets collection with authentication' do
    authenticate
    get collection_url(:buckets)
    last_response.status.must_equal 200
  end

  it 'should support the JSON media type' do
    authenticate
    header 'Accept', 'application/json'
    get collection_url(:buckets)
    last_response.status.must_equal 200
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must include the ETag in HTTP headers' do
    authenticate
    get collection_url(:buckets)
    last_response.headers['ETag'].wont_be_nil
  end

  it 'must have the "buckets" element on top level' do
    authenticate
    get collection_url(:buckets)
    xml_response.root.name.must_equal 'buckets'
  end

  it 'must have some "bucket" elements inside "buckets"' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').wont_be_empty
  end

  it 'must provide the :id attribute for each bucket in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "bucket" element in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the bucket' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must return the list of valid parameters for the :index action' do
    authenticate
    options collection_url(:buckets) + '/index'
    last_response.headers['Allow'].wont_be_nil
  end

  it 'must have the "name" element defined for each bucket in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      (r/'name').wont_be_nil
    end
  end

  it 'must have the "state" element defined for each bucket in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      (r/'state').wont_be_nil
    end
  end

  it 'must return the full "bucket" when following the URL in bucket element' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      get collection_url(:buckets) + '/' + r[:id]
      last_response.status.must_equal 200
    end
  end

  it 'must have the "name" element for the bucket and it should match with the one in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      get collection_url(:buckets) + '/' + r[:id]
      (xml_response/'name').wont_be_empty
      (xml_response/'name').first.text.must_equal((r/'name').first.text)
    end
  end

  it 'must have the "size" element for the bucket and it should match with the one in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      get collection_url(:buckets) + '/' + r[:id]
      (xml_response/'size').wont_be_empty
      (xml_response/'size').first.text.must_equal((r/'size').first.text)
    end
  end

  it 'must have the "blob" elements for the bucket and it should match with the ones in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      get collection_url(:buckets) + '/' + r[:id]
      (xml_response/'bucket/blob').wont_be_empty
      (xml_response/'bucket/blob').each do |b|
        b[:id].wont_be_nil
        b[:href].wont_be_nil
        b[:href].must_match /^http/
        b[:href].must_match /#{r[:id]}\/#{b[:id]}$/
      end
    end
  end

  it 'must have the "blob" elements for the bucket and it should match with the ones in collection' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      get collection_url(:buckets) + '/' + r[:id]
      (xml_response/'bucket/blob').wont_be_empty
      (xml_response/'bucket/blob').each do |b|
        b[:id].wont_be_nil
        b[:href].wont_be_nil
        b[:href].must_match /^http/
        b[:href].must_match /#{r[:id]}\/#{b[:id]}$/
      end
    end
  end

  it 'must allow to get all blobs details and the details should be set correctly' do
    authenticate
    get collection_url(:buckets)
    (xml_response/'buckets/bucket').each do |r|
      get collection_url(:buckets) + '/' + r[:id]
      (xml_response/'bucket/blob').each do |b|
        get collection_url(:buckets) + '/' + r[:id] + '/' + b[:id]
        xml_response.root.name.must_equal 'blob'
        xml_response.root[:id].must_equal b[:id]
        (xml_response/'bucket').wont_be_empty
        (xml_response/'bucket').size.must_equal 1
        (xml_response/'bucket').first.text.wont_be_nil
        (xml_response/'bucket').first.text.must_equal r[:id]
        (xml_response/'content_length').wont_be_empty
        (xml_response/'content_length').size.must_equal 1
        (xml_response/'content_length').first.text.must_match /^(\d+)$/
        (xml_response/'content_type').wont_be_empty
        (xml_response/'content_type').size.must_equal 1
        (xml_response/'content_type').first.text.wont_be_empty
        (xml_response/'last_modified').wont_be_empty
        (xml_response/'last_modified').size.must_equal 1
        (xml_response/'last_modified').first.text.wont_be_empty
        (xml_response/'content').wont_be_empty
        (xml_response/'content').size.must_equal 1
        (xml_response/'content').first[:rel].wont_be_nil
        (xml_response/'content').first[:rel].must_equal 'blob_content'
        (xml_response/'content').first[:href].wont_be_nil
        (xml_response/'content').first[:href].must_match /^http/
        (xml_response/'content').first[:href].must_match /\/content$/
      end
    end
  end

end
