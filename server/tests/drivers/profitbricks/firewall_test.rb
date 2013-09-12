require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'Profitbricks data conversions' do

  before do
    Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.send(:public, *Deltacloud::Drivers::Profitbricks::ProfitbricksDriver.private_instance_methods)
    @driver = Deltacloud::new(:profitbricks, credentials)

    @nic = ::Profitbricks::Nic.new(:id => '1234a',
                                   :name => 'test',
                                   :server_id => 'server-id',
                                   :lan_id => 1,
                                   :firewall => {},
                                   :ips => ['127.0.0.1'])
    @fwr = ::Profitbricks::FirewallRule.new(:id => '1234a',
                                            :protocol => 'TCP',
                                            :port_range_start => 80,
                                            :port_range_end => 81,
                                            :source_ip => '0.0.0.0')
    @fw = ::Profitbricks::Firewall.new(:id => '1234a',
                                       :nic_id => '5678a',
                                       :rules => [@fwr.attributes])
    @credentials = MiniTest::Mock.new
    @credentials.expect(:user, 'test')
    @credentials.expect(:password, 'test')
  end

  it "must find all firewalls" do
    server = MiniTest::Mock.new
    server.expect(:nics, [@nic])
    @nic.stub(:firewall, @fw) do
      ::Profitbricks::Server.stub(:all, [server]) do
        @driver.backend.firewalls(@credentials)
      end
    end
  end

  it "must be deletable" do
    ::Profitbricks::Firewall.stub(:find, @fw) do
      ::Profitbricks.stub(:request, true) do
        @driver.backend.delete_firewall(@credentials, :id => '!234a')
      end
    end
  end

  it "must be able to create firewall rules" do
    fw = MiniTest::Mock.new
    fw.expect(:add_rules, true, [[@fwr]])
    ::Profitbricks::FirewallRule.stub(:new, @fwr) do
      ::Profitbricks::Firewall.stub(:find, fw) do
        @driver.backend.create_firewall_rule(@credentials, :addresses => ['127.0.0.1'], :protocol => 'TCP', :port_from => 80, :port_to => 81)
      end
    end
  end

  it "must delete a firewall rule" do
    fw = MiniTest::Mock.new
    fw.expect(:rules, [@fwr])
    ::Profitbricks::Firewall.stub(:find, fw) do
      ::Profitbricks.stub(:request, true) do
        @driver.backend.delete_firewall_rule(@credentials, :firewall => '4567a', :rule_id => '1234a' )
      end
    end
  end
end
