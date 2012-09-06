require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::HardwareProfiles do

  before do
    def app; run_frontend; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:hardware_profiles)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Sinatra::Rabbit::HardwareProfilesCollection::IndexOperation
  end

  it 'has show operation' do
    @collection.operation(:show).must_equal Sinatra::Rabbit::HardwareProfilesCollection::ShowOperation
  end

  it 'returns list of hardware profiles in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/hardware_profiles'
      status.must_equal 200
    end
  end

  it 'returns details about hardware profile in various formats with show operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/hardware_profiles/m1-small'
      status.must_equal 200
    end
  end

  it 'returns details for various hardware profile configurations' do
    get root_url + '/hardware_profiles'
    status.must_equal 200
    (xml/'hardware_profiles/hardware_profile').each do |hwp|
      get root_url + '/hardware_profiles/' + hwp[:id]
      status.must_equal 200
      xml.root[:id].must_equal hwp[:id]
    end
  end

  it 'reports 404 when querying non-existing hardware profile' do
    get root_url + '/hardware_profiles/unknown'
    status.must_equal 404
  end

end
