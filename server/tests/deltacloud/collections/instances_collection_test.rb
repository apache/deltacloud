require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative File.join('..', 'common.rb')

describe Deltacloud::Collections::Instances do

  before do
    def app; run_frontend; end
    authorize 'mockuser', 'mockpassword'
    @collection = Deltacloud::Collections.collection(:instances)
  end

  it 'has index operation' do
    @collection.operation(:index).must_equal Deltacloud::Rabbit::InstancesCollection::IndexOperation
  end

  it 'provides URL to specify new instance' do
    header 'Accept', 'text/html'
    get root_url + '/instances/new?image_id=img1'
    status.must_equal 200
  end

  it 'returns list of instances in various formats with index operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/instances'
      status.must_equal 200
    end
  end

  it 'returns details about instance in various formats with show operation' do
    formats.each do |format|
      header 'Accept', format
      get root_url + '/instances/inst1'
      status.must_equal 200
    end
  end

  it 'allow to create and execute actions on created instance' do
    post root_url + '/instances', { :image_id => 'img1', :name => 'test', }
    status.must_equal 201
    instance_id = xml.root[:id]
    instance_id.wont_be_nil
    delete root_url + '/instances/' + instance_id
    status.must_equal 405
    # You can't remove RUNNING instance
    (xml/'error/message').first.text.strip.must_equal 'Method Not Allowed'
    post root_url + '/instances/' + instance_id + '/reboot'
    status.must_equal 202
    (xml/'instance/state').first.text.strip.must_equal 'RUNNING'
    post root_url + '/instances/' + instance_id + '/stop'
    status.must_equal 202
    (xml/'instance/state').first.text.strip.must_equal 'STOPPED'
    post root_url + '/instances/' + instance_id + '/start'
    status.must_equal 202
    (xml/'instance/state').first.text.strip.must_equal 'RUNNING'
    post root_url + '/instances/' + instance_id + '/stop'
    status.must_equal 202
    (xml/'instance/state').first.text.strip.must_equal 'STOPPED'
    delete root_url + '/instances/' + instance_id
    status.must_equal 204
  end

  it 'properly serialize attributes in JSON' do
    header 'Accept', 'application/json'
    get root_url + "/instances"
    status.must_equal 200
    json['instances'].wont_be_empty
    get root_url + "/instances/inst1"
    status.must_equal 200
    json['instance'].wont_be_empty
    Deltacloud::Instance.attributes.each do |attr|
      attr = attr.to_s.gsub(/_id$/,'') if attr.to_s =~ /_id$/
      next if ['launch_time', 'authn_error', 'firewalls', 'keyname', 'username', 'password', 'instance_profile', 'network_interfaces'].include?(attr.to_s)
      json['instance'].keys.must_include attr.to_s
      json['instance'].keys.must_include 'create_image'
      json['instance'].keys.must_include 'hardware_profile'
    end
  end
end
