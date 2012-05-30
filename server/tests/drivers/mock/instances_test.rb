$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API instances' do
  include Deltacloud::Test

  it 'must advertise have the instances collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link[@rel=instances]').wont_be_empty
  end

  it 'must require authentication to access the "instance" collection' do
    get collection_url(:instances)
    last_response.status.must_equal 401
  end

  it 'should respond with HTTP_OK when accessing the :instances collection with authentication' do
    authenticate
    get collection_url(:instances)
    last_response.status.must_equal 200
  end

  it 'should support the JSON media type' do
    authenticate
    header 'Accept', 'application/json'
    get collection_url(:instances)
    last_response.status.must_equal 200
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must include the ETag in HTTP headers' do
    authenticate
    get collection_url(:instances)
    last_response.headers['ETag'].wont_be_nil
  end

  it 'must have the "instances" element on top level' do
    authenticate
    get collection_url(:instances)
    xml_response.root.name.must_equal 'instances'
  end

  it 'must have some "instance" elements inside "instances"' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').wont_be_empty
  end

  it 'must provide the :id attribute for each instance in collection' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "instance" element in collection' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the instance' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must return the list of valid parameters for the :index action' do
    authenticate
    options collection_url(:instances) + '/index'
    last_response.headers['Allow'].wont_be_nil
  end

  it 'must have the "name" element defined for each instance in collection' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      (r/'name').wont_be_empty
    end
  end

  it 'must have the "state" element defined for each instance in collection' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      (r/'state').wont_be_empty
      (r/'state').first.must_match /(RUNNING|STOPPED|PENDING)/
    end
  end

  it 'must return the full "instance" when following the URL in instance element' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      last_response.status.must_equal 200
    end
  end

  it 'must have the "name" element for the instance and it should match with the one in collection' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'name').wont_be_empty
      (xml_response/'name').first.text.must_equal((r/'name').first.text)
    end
  end

  it 'must have the "name" element for the instance and it should match with the one in collection' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'state').wont_be_empty
      (xml_response/'state').first.text.must_equal((r/'state').first.text)
    end
  end

  it 'must have the "owner_id" element for the instance and it should match with the one in collection' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'owner_id').wont_be_empty
      (xml_response/'owner_id').first.text.must_equal((r/'owner_id').first.text)
    end
  end

  it 'must link to the realm that was used to during instance creation' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'realm').wont_be_empty
      (xml_response/'realm').size.must_equal 1
      (xml_response/'realm').first[:id].wont_be_nil
      (xml_response/'realm').first[:href].wont_be_nil
      (xml_response/'realm').first[:href].must_match /\/#{(xml_response/'realm').first[:id]}$/
    end
  end

  it 'must link to the image that was used to during instance creation' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'image').wont_be_empty
      (xml_response/'image').size.must_equal 1
      (xml_response/'image').first[:id].wont_be_nil
      (xml_response/'image').first[:href].wont_be_nil
      (xml_response/'image').first[:href].must_match /\/#{(xml_response/'image').first[:id]}$/
    end
  end

  it 'must link to the hardware_profile that was used to during instance creation' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'hardware_profile').wont_be_empty
      (xml_response/'hardware_profile').size.must_equal 1
      (xml_response/'hardware_profile').first[:id].wont_be_nil
      (xml_response/'hardware_profile').first[:href].wont_be_nil
      (xml_response/'hardware_profile').first[:href].must_match /\/#{(xml_response/'hardware_profile').first[:id]}$/
    end
  end

  it 'should advertise the public and private addresses of the instance' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'public_addresses').wont_be_empty
      (xml_response/'public_addresses').size.must_equal 1
      (xml_response/'public_addresses/address').each do |a|
        a[:type].wont_be_nil
        a.text.strip.wont_be_empty
      end
      (xml_response/'private_addresses').wont_be_empty
      (xml_response/'private_addresses').size.must_equal 1
      (xml_response/'private_addresses/address').each do |a|
        a[:type].wont_be_nil
        a.text.strip.wont_be_empty
      end
    end
  end

  it 'should advertise the storage volumes used by the instance' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'storage_volumes').wont_be_empty
    end
  end

  it 'should advertise the list of actions that can be executed for each instance' do
    authenticate
    get collection_url(:instances)
    (xml_response/'instances/instance').each do |r|
      get collection_url(:instances) + '/' + r[:id]
      (xml_response/'actions/link').wont_be_empty
      (xml_response/'actions/link').each do |l|
        l[:href].wont_be_nil
        l[:href].must_match /^http/
        l[:method].wont_be_nil
        l[:rel].wont_be_nil
      end
    end
  end

  it 'should allow to create and destroy new instance using the first available image without realm' do
    authenticate
    get collection_url(:images)
    image_id = (xml_response/'images/image').first[:id]
    image_id.wont_be_nil
    post collection_url(:instances), {
      :image_id => image_id
    }
    last_response.status.must_equal 201 # HTTP_CREATED
    last_response.headers['Location'].wont_be_nil # Location header must be set, pointing to new the instance
    instance_id = last_response.headers['Location'].split('/').last
    # Get the instance and check if ID and image is set correctly
    get collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 200 # HTTP_OK
    (xml_response/'instance').first[:id].must_equal instance_id
    (xml_response/'instance/image').first[:id].must_equal image_id
    # If instance is RUNNING then stop it
    if (xml_response/'instance/state').first.text == 'RUNNING'
      post collection_url(:instances) + '/' + instance_id + '/stop'
      last_response.status.must_equal 202 # HTTP_NO_CONTENT
    end
    # Delete created instance
    delete collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 204 # HTTP_NO_CONTENT
  end

  it 'should allow to create and destroy new instance using the first available image within first realm' do
    authenticate
    get collection_url(:images)
    image_id = (xml_response/'images/image').first[:id]
    get collection_url(:realms)
    realm_id = (xml_response/'realms/realm').first[:id]
    image_id.wont_be_nil
    realm_id.wont_be_nil
    post collection_url(:instances), {
      :image_id => image_id,
      :realm_id => realm_id,
    }
    last_response.status.must_equal 201 # HTTP_CREATED
    last_response.headers['Location'].wont_be_nil # Location header must be set, pointing to new the instance
    instance_id = last_response.headers['Location'].split('/').last
    # Get the instance and check if ID and image is set correctly
    get collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 200 # HTTP_OK
    (xml_response/'instance').first[:id].must_equal instance_id
    (xml_response/'instance/image').first[:id].must_equal image_id
    (xml_response/'instance/realm').first[:id].must_equal realm_id
    # If instance is RUNNING then stop it
    if (xml_response/'instance/state').first.text == 'RUNNING'
      post collection_url(:instances) + '/' + instance_id + '/stop'
      last_response.status.must_equal 202 # HTTP_NO_CONTENT
    end
    # Delete created instance
    delete collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 204 # HTTP_NO_CONTENT
  end

  it 'should allow to create and destroy new instance using the first available image with user defined name' do
    authenticate
    get collection_url(:images)
    image_id = (xml_response/'images/image').first[:id]
    image_id.wont_be_nil
    name = "i#{Time.now.to_i}"
    post collection_url(:instances), {
      :image_id => image_id,
      :name => name
    }
    last_response.status.must_equal 201 # HTTP_CREATED
    last_response.headers['Location'].wont_be_nil # Location header must be set, pointing to new the instance
    instance_id = last_response.headers['Location'].split('/').last
    # Get the instance and check if ID and image is set correctly
    get collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 200 # HTTP_OK
    (xml_response/'instance').first[:id].must_equal instance_id
    (xml_response/'instance/image').first[:id].must_equal image_id
    (xml_response/'instance/name').first.text.must_equal name
    # If instance is RUNNING then stop it
    if (xml_response/'instance/state').first.text == 'RUNNING'
      post collection_url(:instances) + '/' + instance_id + '/stop'
      last_response.status.must_equal 202 # HTTP_NO_CONTENT
    end
    # Delete created instance
    delete collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 204 # HTTP_NO_CONTENT
  end

  it 'should allow to create and destroy new instance using the first available image and first hardware_profile' do
    authenticate
    get collection_url(:images)
    image_id = (xml_response/'images/image').first[:id]
    get collection_url(:hardware_profiles)
    hwp_id = (xml_response/'hardware_profiles/hardware_profile').first[:id]
    image_id.wont_be_nil
    name = "i#{Time.now.to_i}"
    post collection_url(:instances), {
      :image_id => image_id,
      :hwp_id => hwp_id
    }
    last_response.status.must_equal 201 # HTTP_CREATED
    last_response.headers['Location'].wont_be_nil # Location header must be set, pointing to new the instance
    instance_id = last_response.headers['Location'].split('/').last
    # Get the instance and check if ID and image is set correctly
    get collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 200 # HTTP_OK
    (xml_response/'instance').first[:id].must_equal instance_id
    (xml_response/'instance/image').first[:id].must_equal image_id
    (xml_response/'instance/hardware_profile').first[:id].must_equal hwp_id
    # If instance is RUNNING then stop it
    if (xml_response/'instance/state').first.text == 'RUNNING'
      post collection_url(:instances) + '/' + instance_id + '/stop'
      last_response.status.must_equal 202 # HTTP_NO_CONTENT
    end
    # Delete created instance
    delete collection_url(:instances) + '/' + instance_id
    last_response.status.must_equal 204 # HTTP_NO_CONTENT
  end

end
