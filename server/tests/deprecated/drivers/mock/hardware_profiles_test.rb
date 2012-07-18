$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/mock/common'

describe 'Deltacloud API Hardware Profiles' do
  include Deltacloud::Test

  it 'must advertise have the hardware_profiles collection in API entrypoint' do
    get root_url
    (xml_response/'api/link[@rel=hardware_profiles]').wont_be_empty
  end

  it 'should respond with HTTP_OK when accessing the :hardware_profiles collection with authentication' do
    authenticate
    get collection_url(:hardware_profiles)
    last_response.status.must_equal 200
  end

  it 'should support the JSON media type' do
    authenticate
    header 'Accept', 'application/json'
    get collection_url(:hardware_profiles)
    last_response.status.must_equal 200
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must include the ETag in HTTP headers' do
    authenticate
    get collection_url(:hardware_profiles)
    last_response.headers['ETag'].wont_be_nil
  end

  it 'must have the "hardware_profiles" element on top level' do
    authenticate
    get collection_url(:hardware_profiles)
    xml_response.root.name.must_equal 'hardware_profiles'
  end

  it 'must have some "hardware_profile" elements inside "hardware_profiles"' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').wont_be_empty
  end

  it 'must provide the :id attribute for each hardware_profile in collection' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      r[:id].wont_be_nil
    end
  end

  it 'must include the :href attribute for each "hardware_profile" element in collection' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      r[:href].wont_be_nil
    end
  end

  it 'must use the absolute URL in each :href attribute' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      r[:href].must_match /^http/
    end
  end

  it 'must have the URL ending with the :id of the hardware_profile' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      r[:href].must_match /#{r[:id]}$/
    end
  end

  it 'must return the list of valid parameters for the :index action' do
    authenticate
    options collection_url(:hardware_profiles) + '/index'
    last_response.headers['Allow'].wont_be_nil
  end

  it 'must have the "name" element defined for each hardware_profile in collection' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      (r/'name').wont_be_empty
    end
  end

  it 'should have the "property" element defined if not the opaque hardware_profile' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').wont_be_empty
    end
  end

  it 'must define the :kind attribute for each "property" ' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each { |p| p[:kind].wont_be_nil }
    end
  end

  it 'must define the :name attribute for each "property" ' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each { |p| p[:name].wont_be_nil }
    end
  end

  it 'must define the :unit attribute for each "property" ' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each { |p| p[:unit].wont_be_nil }
    end
  end

  it 'must define the :value attribute for each "property" ' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each { |p| p[:value].wont_be_nil }
    end
  end

  it 'must define the "param" element if property kind is not "fixed"' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each do |p|
        next if p[:kind] == 'fixed'
        (p/'param').wont_be_empty
        (p/'param').size.must_equal 1
        (p/'param').first[:href].wont_be_nil
        (p/'param').first[:href].must_match /^http/
        (p/'param').first[:method].wont_be_nil
        (p/'param').first[:name].wont_be_nil
        (p/'param').first[:operation].wont_be_nil
      end
    end
  end

  it 'must provide the list of valid values when the property is defined as "enum"' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each do |p|
        next if p[:kind] != 'enum'
        (p/'enum/entry').wont_be_empty
        (p/'enum/entry').each { |e| e[:value].wont_be_nil }
      end
    end
  end

  it 'must provide the range of valid values when the property is defined as "range"' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each do |p|
        next if p[:kind] != 'range'
        (p/'range').wont_be_empty
        (p/'range').size.must_equal 1
        (p/'range').first[:first].wont_be_nil
        (p/'range').first[:last].wont_be_nil
      end
    end
  end

  it 'must provide the default value within the range if property defined as "range"' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each do |p|
        next if p[:kind] != 'range'
        ((p/'range').first[:first].to_i..(p/'range').first[:last].to_i).include?(p[:value].to_i).must_equal true
      end
    end
  end

  it 'must provide the default value that is included in enum list if property defined as "enum"' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      next if r[:id] == 'opaque'
      (r/'property').each do |p|
        next if p[:kind] != 'enum'
        (p/'enum/entry').map { |e| e[:value] }.include?(p[:value]).must_equal true
      end
    end
  end

  it 'must return the full "hardware_profile" when following the URL in hardware_profile element' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      get collection_url(:hardware_profiles) + '/' + r[:id]
      last_response.status.must_equal 200
    end
  end

  it 'must have the "name" element for the hardware_profile and it should match with the one in collection' do
    authenticate
    get collection_url(:hardware_profiles)
    (xml_response/'hardware_profiles/hardware_profile').each do |r|
      get collection_url(:hardware_profiles) + '/' + r[:id]
      (xml_response/'name').wont_be_empty
      (xml_response/'name').first.text.must_equal((r/'name').first.text)
    end
  end

end
