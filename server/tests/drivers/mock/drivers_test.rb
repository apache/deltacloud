$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API drivers' do
  include Deltacloud::Test

  it 'must advertise have the drivers collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link[@rel=drivers]').wont_be_empty
  end

  it 'must not require authentication to access the "driver" collection' do
    get collection_url(:drivers)
    last_response.status.must_equal 200
  end

  it 'should respond with HTTP_OK when accessing the :drivers collection with authentication' do
    get collection_url(:drivers)
    last_response.status.must_equal 200
  end

  it 'should support the JSON media type' do
    header 'Accept', 'application/json'
    get collection_url(:drivers)
    last_response.status.must_equal 200
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must include the ETag in HTTP headers' do
    get collection_url(:drivers)
    last_response.headers['ETag'].wont_be_nil
  end

  it 'must have the "drivers" element on top level' do
    get collection_url(:drivers)
    xml_response.root.name.must_equal 'drivers'
  end

  it 'must have some "driver" elements inside "drivers"' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').wont_be_empty
  end

  it 'must provide the :id attribute for each driver in collection' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "driver" element in collection' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the driver' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must return the list of valid parameters for the :index action' do
    options collection_url(:drivers) + '/index'
    last_response.headers['Allow'].wont_be_nil
  end

  it 'must have the "name" element defined for each driver in collection' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').each do |r|
      (r/'name').wont_be_nil
    end
  end


  it 'must return the full "driver" when following the URL in driver element' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').each do |r|
      get collection_url(:drivers) + '/' + r[:id]
      last_response.status.must_equal 200
    end
  end

  it 'must have the "name" element for the driver and it should match with the one in collection' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver').each do |r|
      get collection_url(:drivers) + '/' + r[:id]
      (xml_response/'name').wont_be_empty
      (xml_response/'name').first.text.must_equal((r/'name').first.text)
    end
  end

  it 'should advertise available providers for some drivers' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver/provider').each do |p|
      p[:id].wont_be_nil
    end
  end

  it 'should expose entrypoints for each provider if driver has providers defined' do
    get collection_url(:drivers)
    (xml_response/'drivers/driver/provider').each do |p|
      get collection_url(:drivers) + '/' + p.parent[:id]
      (xml_response/"driver/provider[@id=#{p[:id]}]").wont_be_empty
      (xml_response/"driver/provider[@id=#{p[:id]}]").size.must_equal 1
      (xml_response/"driver/provider[@id=#{p[:id]}]/entrypoint").wont_be_empty
      (xml_response/"driver/provider[@id=#{p[:id]}]/entrypoint").each do |e|
        e[:kind].wont_be_nil
        e.text.wont_be_empty
      end
    end
  end

end
