$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API Images' do
  include Deltacloud::Test

  it 'must advertise have the images collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link[@rel=images]').wont_be_empty
  end

  it 'must require authentication to access the "image" collection' do
    get collection_url(:images)
    last_response.status.must_equal 401
  end

  it 'should respond with HTTP_OK when accessing the :images collection with authentication' do
    auth_as_mock
    get collection_url(:images)
    last_response.status.must_equal 200
  end

  it 'should support the JSON media type' do
    auth_as_mock
    header 'Accept', 'application/json'
    get collection_url(:images)
    last_response.status.must_equal 200
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must include the ETag in HTTP headers' do
    auth_as_mock
    get collection_url(:images)
    last_response.headers['ETag'].wont_be_nil
  end

  it 'must have the "images" element on top level' do
    auth_as_mock
    get collection_url(:images)
    xml_response.root.name.must_equal 'images'
  end

  it 'must have some "image" elements inside "images"' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').wont_be_empty
  end

  it 'must provide the :id attribute for each image in collection' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "image" element in collection' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the image' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must return the list of valid parameters for the :index action' do
    auth_as_mock
    options collection_url(:images) + '/index'
    last_response.headers['Allow'].wont_be_nil
  end

  it 'must have the "name" element defined for each image in collection' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      (r/'name').wont_be_empty
    end
  end

  it 'must have the "state" element defined for each image in collection' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      (r/'state').wont_be_empty
    end
  end

  it 'must return the full "image" when following the URL in image element' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      last_response.status.must_equal 200
    end
  end

  it 'must have the "name" element for the image and it should match with the one in collection' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      (xml_response/'name').wont_be_empty
      (xml_response/'name').first.text.must_equal((r/'name').first.text)
    end
  end

  it 'must have the "name" element for the image and it should match with the one in collection' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      (xml_response/'state').wont_be_empty
      (xml_response/'state').first.text.must_equal((r/'state').first.text)
    end
  end

  it 'should have the "owner_id" element for each image' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      (xml_response/'owner_id').wont_be_empty
    end
  end

  it 'should have the "description" element for each image' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      (xml_response/'description').wont_be_empty
    end
  end

  it 'should have the "architecture" element for each image' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      (xml_response/'architecture').wont_be_empty
    end
  end

  it 'should include the list of compatible hardware_profiles for each image' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      (xml_response/'hardware_profiles/hardware_profile').wont_be_empty
      (xml_response/'hardware_profiles/hardware_profile').each do |hwp|
        hwp[:href].wont_be_nil
        hwp[:href].must_match /^http/
        hwp[:id].wont_be_nil
        hwp[:href].must_match /\/#{hwp[:id]}$/
        hwp[:rel].must_equal 'hardware_profile'
      end
    end
  end

  it 'should advertise the list of actions that can be executed for each image' do
    auth_as_mock
    get collection_url(:images)
    (xml_response/'images/image').each do |r|
      get collection_url(:images) + '/' + r[:id]
      (xml_response/'actions/link').wont_be_empty
      (xml_response/'actions/link').each do |l|
        l[:href].wont_be_nil
        l[:href].must_match /^http/
        l[:method].wont_be_nil
        l[:rel].wont_be_nil
      end
    end
  end

  it 'should give client HTML form to create new image' do
    auth_as_mock
    header 'Accept', 'text/html'
    get collection_url(:images) + '/new'
    last_response.status.must_equal 200
  end

end
