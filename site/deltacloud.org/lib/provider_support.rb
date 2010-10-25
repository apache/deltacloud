module ProviderSupportHelper
  def provider_support
    [
      {:name => "Amazon EC2", :driver => true, :instance => { :create => true, :start => false, :stop => true, :reboot => true, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
      {:name => "GoGrid", :driver => true, :instance => { :create => true, :start => false, :stop => true, :reboot => true, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
      {:name => "OpenNebula", :driver => true, :instance => { :create => true, :start => true, :stop => true, :reboot => false, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
      {:name => "Rackspace", :driver => true, :instance => { :create => true, :start => false, :stop => true, :reboot => true, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
      {:name => "RHEV-M", :driver => true, :instance => { :create => true, :start => true, :stop => true, :reboot => true, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
      {:name => "RimuHosting", :driver => true, :instance => { :create => true, :start => true, :stop => true, :reboot => true, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
      {:name => "Terremark", :driver => false, :instance => { :create => true, :start => true, :stop => true, :reboot => true, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
      {:name => "vCloud", :driver => false, :instance => { :create => true, :start => true, :stop => true, :reboot => true, :destroy => true },
        :list => { :hardware_profiles => true, :realms => true, :images => true, :instances => true} },
    ]
  end

  def support_indicator(value)
    text = value ? "yes" : "no"
    cls = value ? "supported" : "not-supported"
    "<td class=\"#{cls}\">#{text}</td>"
  end

end

Webby::Helpers.register(ProviderSupportHelper)
