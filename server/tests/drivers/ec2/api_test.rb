$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..')
require 'tests/drivers/ec2/common'

describe 'Deltacloud API' do

  before do
    Timecop.freeze(FREEZED_TIME)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  include Deltacloud::Test

  it 'return HTTP_OK when accessing API entrypoint' do
    get Deltacloud[:root_url]
    last_response.status.must_equal 200
  end

  it 'advertise the current driver in API entrypoint' do
    get Deltacloud[:root_url]
    xml_response.root[:driver].must_equal ENV['API_DRIVER']
  end

  it 'advertise the current API version in API entrypoint' do
    get Deltacloud[:root_url]
    xml_response.root[:version].must_equal Deltacloud[:version]
  end

  it 'advertise the current API version in HTTP headers' do
    get Deltacloud[:root_url]
    last_response.headers['Server'].must_equal "Apache-Deltacloud/#{Deltacloud[:version]}"
  end

  it 'must include the ETag in HTTP headers' do
    get Deltacloud[:root_url]
    last_response.headers['ETag'].wont_be_nil
  end

  it 'advertise collections in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link').wont_be_empty
  end

  it 'include the :href and :rel attribute for each collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link').each do |collection|
      collection[:href].wont_be_nil
      collection[:rel].wont_be_nil
    end
  end

  it 'uses the absolute URI in the :href attribute for each collection in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link').each do |collection|
      collection[:href].must_match /^http/
    end
  end

  it 'advertise features for some collections in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link/feature').wont_be_empty
  end

  it 'advertise the name of the feature for some collections in API entrypoint' do
    get Deltacloud[:root_url]
    (xml_response/'api/link/feature').each do |f|
      f[:name].wont_be_nil
    end
  end

  it 'must change the media type from XML to JSON using Accept headers' do
    header 'Accept', 'application/json'
    get Deltacloud[:root_url]
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must change the media type to JSON using the "?format" parameter in URL' do
    get Deltacloud[:root_url], { :format => 'json' }
    last_response.headers['Content-Type'].must_equal 'application/json'
  end

  it 'must change the driver when using X-Deltacloud-Driver HTTP header' do
    header 'X-Deltacloud-Driver', 'ec2'
    get Deltacloud[:root_url]
    xml_response.root[:driver].must_equal 'ec2'
    header 'X-Deltacloud-Driver', 'mock'
    get Deltacloud[:root_url]
    xml_response.root[:driver].must_equal 'mock'
  end

  it 'must change the features when driver is swapped using HTTP headers' do
    header 'X-Deltacloud-Driver', 'ec2'
    get Deltacloud[:root_url]
    # The 'user_name' feature is not supported currently for the EC2 driver
    (xml_response/'api/link/feature').map { |f| f[:name] }.wont_include 'user_name'
    header 'X-Deltacloud-Driver', 'mock'
    get Deltacloud[:root_url]
    # But it's supported in Mock driver
    (xml_response/'api/link/feature').map { |f| f[:name] }.must_include 'user_name'
  end

  it 'must re-validate the driver credentials when using "?force_auth" parameter in URL' do
    get Deltacloud[:root_url], { :force_auth => '1' }
    last_response.status.must_equal 401
    auth_as_mock
    get Deltacloud[:root_url], { :force_auth => '1' }
    last_response.status.must_equal 200
  end

  it 'must change the API PROVIDER using the /api;provider matrix parameter in URI' do
    get Deltacloud[:root_url] + ';provider=test1'
    xml_response.root[:provider].wont_be_nil
    xml_response.root[:provider].must_equal 'test1'
    get Deltacloud[:root_url] + ';provider=test2'
    xml_response.root[:provider].must_equal 'test2'
  end

  it 'must change the API DRIVER using the /api;driver matrix parameter in URI' do
    get Deltacloud[:root_url] + ';driver=ec2'
    xml_response.root[:driver].must_equal 'ec2'
    get Deltacloud[:root_url] + ';driver=mock'
    xml_response.root[:driver].must_equal 'mock'
  end

end
