require 'minitest/autorun'

require_relative 'common.rb'
require_relative File.join('..', '..', 'lib', 'deltacloud', 'api.rb')

describe Deltacloud::EC2 do

  describe Deltacloud::EC2::ActionHandler do

    before do
      @handler = Deltacloud::EC2::ActionHandler
    end

    it 'provides access to mappings' do
      @handler.mappings.wont_be_nil
      @handler.mappings.must_be_kind_of Hash
    end

  end

  describe Deltacloud::EC2::QueryParser do

    before do
      @parser = Deltacloud::EC2::QueryParser
    end

    it 'parse request parameters and assign the action' do
      result = @parser.parse({'Action' => 'DescribeAvailabilityZones', 'ZoneName.1' => 'us'}, '1')
      result.wont_be_nil
      result.must_be_kind_of Deltacloud::EC2::ActionHandler
      result.action.wont_be_nil
      result.action.must_be_kind_of @parser
      result.action.action.must_equal :describe_availability_zones
      result.action.request_id.must_equal '1'
      result.action.parameters.wont_be_nil
      result.action.parameters.must_be_kind_of Hash
      result.action.parameters['ZoneName.1'].must_equal 'us'
    end

    it 'must provide verification for actions' do
      result = @parser.parse({'Action' => 'DescribeAvailabilityZones', 'ZoneName.1' => 'us'}, '1')
      result.wont_be_nil
      result.must_be_kind_of Deltacloud::EC2::ActionHandler
      result.action.wont_be_nil
      result.action.must_be_kind_of @parser
      result.action.valid_actions.wont_be_nil
      result.action.valid_actions.must_include :describe_availability_zones
      result.action.valid_action?.must_equal true
    end

    it 'must provide the Deltacloud method for EC2 action' do
      result = @parser.parse({'Action' => 'DescribeAvailabilityZones', 'ZoneName.1' => 'us'}, '1')
      result.wont_be_nil
      result.must_be_kind_of Deltacloud::EC2::ActionHandler
      result.deltacloud_method.must_equal :realms
      result.deltacloud_method_params[:id].wont_be_nil
      result.deltacloud_method_params[:id].must_equal 'us'
    end

  end

  describe Deltacloud::EC2::ResultParser do

    before do
      @parser = Deltacloud::EC2::QueryParser
      @driver = Deltacloud::new(:mock, :user => 'mockuser', :password => 'mockpassword')
      def app; Deltacloud::EC2::API; end
    end

    it 'must perform the EC2 action on Deltacloud driver' do
      result = @parser.parse({'Action' => 'DescribeAvailabilityZones', 'ZoneName.1' => 'us'}, '1')
      result.wont_be_nil
      result.must_be_kind_of Deltacloud::EC2::ActionHandler
      result.action.wont_be_nil
      result.action.must_be_kind_of @parser
      result.must_respond_to :'perform!'
      realms = result.perform!(@driver.credentials, @driver.backend)
      realms.wont_be_empty
      realms.first.must_be_kind_of Realm
      realms.first.id.must_equal 'us'
    end

    it 'must parse the result of EC2 action to EC2 formatted XML' do
      result = @parser.parse({'Action' => 'DescribeAvailabilityZones', 'ZoneName.1' => 'us'}, '1')
      result.wont_be_nil
      result.must_be_kind_of Deltacloud::EC2::ActionHandler
      result.action.wont_be_nil
      result.action.must_be_kind_of @parser
      result.must_respond_to :'perform!'
      result.perform!(@driver.credentials, @driver.backend)
      result = Nokogiri::XML(result.to_xml(app))
      result.root.name.must_equal 'DescribeAvailabilityZonesResponse'
    end

  end

end
